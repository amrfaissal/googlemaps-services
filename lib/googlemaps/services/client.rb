# coding: utf-8
require 'googlemaps/services/global_constants'
require 'googlemaps/services/exceptions'
require 'googlemaps/services/util'
require 'nokogiri'
require 'base64'
require 'json'
require 'http'

# Core functionality, common across all API requests.
#
# @since 1.0.0
module GoogleMaps
  # Core services that connect to Google Maps API web services.
  #
  # @since 1.0.0
  module Services

    # Performs requests to the Google Maps API web services.
    class GoogleClient
      include GoogleMaps::Services::Exceptions

      # @return [Symbol] API key. Required, unless "client_id" and "client_secret" are set.
      attr_accessor :key
      # @return [Symbol] Write timeout for the HTTP request, in seconds.
      attr_accessor :write_timeout
      # @return [Symbol] Connect timeout for the HTTP request, in seconds.
      attr_accessor :connect_timeout
      # @return [Symbol] Read timeout for the HTTP request, in seconds.
      attr_accessor :read_timeout
      # @return [Symbol] Client ID (for Maps API for Work).
      attr_accessor :client_id
      # @return [Symbol] Base64-encoded client secret (for Maps API for Work).
      attr_accessor :client_secret
      # @return [Symbol] Attribute used for tracking purposes. Can only be used with a Client ID.
      attr_accessor :channel
      # @return [Symbol] Timeout across multiple retriable requests, in seconds.
      attr_accessor :retry_timeout
      # @return [Symbol] HTTP headers per request.
      attr_accessor :request_headers
      # @return [Symbol] number of queries per second permitted. If the rate limit is reached, the client will sleep for the appropriate amout of time before it runs the current query.
      attr_accessor :queries_per_second
      # @return [Symbol] keeps track of sent queries.
      attr_accessor :sent_times
      # @return [Symbol] Response format. Either :json or :xml
      attr_accessor :response_format

      def initialize(key: nil, client_id: nil, client_secret: nil, write_timeout: 1,
                     connect_timeout: 1, read_timeout: 1,retry_timeout: 60, request_headers: {},
                     queries_per_second: 10, channel: nil, response_format: :json)
        unless key || (client_secret && client_id)
          raise StandardError, 'Must provide API key or enterprise credentials when creationg client.'
        end

        if key && !key.start_with?('AIza')
          raise StandardError, 'Invalid API key provided.'
        end

        if channel
          raise StandardError, 'The channel argument must be used with a client ID.' unless client_id


          unless /^[a-zA-Z0-9._-]*$/.match(channel)
            raise StandardError, 'The channel argument must be an ASCII alphanumeric string. The period (.), underscore (_) and hyphen (-) characters are allowed.'
          end
        end

        self.key = key

        # Set the timeout for write/connect/read calls
        self.write_timeout = write_timeout
        self.connect_timeout = connect_timeout
        self.read_timeout = read_timeout

        self.client_id = client_id
        self.client_secret = client_secret
        self.channel = channel
        self.retry_timeout = retry_timeout
        self.request_headers = request_headers.merge({ 'User-Agent' => Constants::USER_AGENT })
        self.queries_per_second = queries_per_second
        self.sent_times = Array.new

        if response_format
          raise StandardError, 'Unsupported response format. Should be either :json or :xml.' unless [:json, :xml].include? response_format
          self.response_format = response_format
        end
      end

      # Performs HTTP GET requests with credentials, returning the body as JSON or XML.
      #
      # @param [String] url URL path for the request. Should begin with a slash.
      # @param [Hash] params HTTP GET parameters.
      # @param [Time] first_request_time The time of the first request (nil if no retries have occurred).
      # @param [Integer] retry_counter The number of this retry, or zero for first attempt.
      # @param [String] base_url The base URL for the request. Defaults to the Google Maps API server. Should not have a trailing slash.
      # @param [TrueClass, FalseClass] accepts_clientid Flag whether this call supports the client/signature params. Some APIs require API keys (e.g. Roads).
      # @param [Proc] extract_body A function that extracts the body from the request. If the request was not successful, the function should raise a
      #               GoogleMaps::Services::Exceptions::HTTPError or GoogleMaps::Services::Exceptions::APIError as appropriate.
      # @param [Hash] request_headers HTTP headers per request.
      #
      # @return [Hash, Array, nil] response body (either in JSON or XML) or nil.
      def get(url:, params:, first_request_time: nil, retry_counter: nil, base_url: Constants::DEFAULT_BASE_URL,
              accepts_clientid: true, extract_body: nil, request_headers: nil)
        first_request_time = Util.current_time unless first_request_time

        elapsed = Time.now - first_request_time
        if elapsed > self.retry_timeout
          raise Timeout
        end

        if retry_counter && retry_counter > 0
          # 0.5 * (1.5 ^ i) is an increased sleep time of 1.5x per iteration,
          # starting at 0.5s when retry_counter=0. The first retry will occur
          # at 1, so subtract that first.
          delay_seconds = 0.5 * 1.5 ** (retry_counter - 1)
          # Jitter this value by 50% and pause.
          sleep(delay_seconds * (Random.rand + 0.5))
        end

        authed_url = generate_auth_url(url, params, accepts_clientid)

        # Default to the client-level self.request_headers, with method-level
        # request_headers arg overriding.
        request_headers = self.request_headers.merge(request_headers || {})

        # Construct the Request URI
        uri = HTTP::URI.parse(base_url + authed_url)

        # Create the request, add the headers and make the GET request
        resp = HTTP.headers(request_headers)
                   .timeout(:write => self.write_timeout, :connect => self.connect_timeout, :read => self.read_timeout)
                   .get(uri.to_s)

        if Constants::RETRIABLE_STATUSES.include? resp.code.to_i
          # Retry request
          self.get(url, params, first_request_time, retry_counter + 1, base_url, accepts_clientid, extract_body)
        end

        # Check if the time of the nth previous query (where n is queries_per_second)
        # is under a second ago - if so, sleep for the difference.
        if self.sent_times && (self.sent_times.length == self.queries_per_second)
          elapsed_since_earliest = Util.current_time - self.sent_times[0]
          if elapsed_since_earliest < 1
            sleep(1 - elapsed_since_earliest)
          end
        end

        begin
          # Extract HTTP response body
          if extract_body
            result = extract_body.call(resp)
          else
            case resp.content_type.mime_type
            when 'application/xml'
              result = get_xml_body(resp)
            when 'application/json'
              result = get_json_body(resp)
            when 'text/html'
              result = get_redirection_url(resp)
            else
              result = get_map_image(resp)
            end
          end
          self.sent_times.push(Util.current_time)
          return result
        rescue RetriableRequest
          # Retry request
          return self.get(url, params, first_request_time, retry_counter + 1, base_url, accepts_clientid, extract_body)
        end
      end

      # Returns the redirection URL from the Response in case of 3XX status code.
      #
      # @private
      #
      # @param [Net::HTTPResponse] resp HTTP response object.
      #
      # @return [String] Redirection URL.
      def get_redirection_url(resp)
        status_code = resp.code.to_i
        (status_code >= 300 && status_code < 400) ? resp['location'] : nil
      end

      # Extracts the JSON body of the HTTP response.
      #
      # @private
      #
      # @param [Net::HTTPResponse] resp HTTP response object.
      #
      # @return [Hash, Array] Valid JSON response.
      def get_json_body(resp)
        status_code = resp.code.to_i

        if status_code != 200
          raise HTTPError.new(status_code)
        end

        # Parse the JSON response body
        begin
          body = JSON.parse(resp.body)
        rescue JSON::ParserError
          raise APIError.new(status_code), 'Received a malformed JSON response.'
        end

        api_status = body['status']
        if api_status == 'OK' || api_status == 'ZERO_RESULTS'
          return body
        end

        if api_status == 'OVER_QUERY_LIMIT'
          raise RetriableRequest
        end

        if body.key?('error_message')
          raise APIError.new(api_status), body['error_message']
        end
      end

      # Extracts the XML body of the HTTP response.
      #
      # @private
      #
      # @param [Net::HTTPResponse] resp HTTP response object.
      #
      # @return [Nokogiri::XML::Document] Valid XML document.
      def get_xml_body(resp)
        status_code = resp.code.to_i

        if status_code != 200
          raise HTTPError.new(status_code)
        end

        # Parse the XML response body
        begin
          doc = Nokogiri::XML(resp.body) { |config| config.strict }
        rescue
          raise APIError.new(status_code), 'Received a malformed XML response.'
        end

        api_status = doc.xpath('//status').first.text
        if api_status == 'OK' || api_status == 'ZERO_RESULTS'
          return doc
        end

        if api_status == 'OVER_QUERY_LIMIT'
          raise RetriableRequest
        end

        error_message = doc.xpath('//error_message')
        if error_message
          raise APIError.new(api_status), error_message.text
        end
      end

      # Extracts the static map image from the HTTP response.
      #
      # @private
      #
      # @param [Net::HTTPResponse] resp HTTP response object.
      #
      # @return [Hash] Hash with image URL, MIME type and its base64-encoded value.
      def get_map_image(resp)
        status_code = resp.code.to_i

        if status_code != 200
          raise HTTPError.new(status_code)
        end

        {
          :url => resp.uri.to_s,
          :mime_type => resp.content_type.mime_type,
          :image_data => Base64.encode64(resp.body).gsub(/\n/, '')
        }
      end

      # Returns the path and query string portion of the request URL, first adding any necessary parameters.
      #
      # @private
      #
      # @param [String] path The path portion of the URL.
      # @param [Hash] params URL parameters.
      # @param [TrueClass, FalseClass] accepts_clientid Flag whether to use a Client ID or not.
      #
      # @return [String] the final request path.
      def generate_auth_url(path, params={}, accepts_clientid)
        if accepts_clientid && self.client_id && self.client_secret
          if self.channel
            params['channel'] = self.channel
          end
          params['client'] = self.client_id

          path = [path, Util.urlencode_params(params)].join('?')
          sig = Util.sign_hmac(self.client_secret, path)
          return path + '&signature=' + sig
        end

        raise StandardError, 'Must provide API key for this API. It does not accept enterprise credentials.' unless self.key

        params['key'] = self.key
        return path + '?' + Util.urlencode_params(params)
      end

      private :get_json_body, :get_xml_body, :get_map_image, :get_redirection_url, :generate_auth_url
    end

  end
end
