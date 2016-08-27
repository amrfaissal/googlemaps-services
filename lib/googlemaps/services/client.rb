require "googlemaps/services/exceptions"
require "googlemaps/services/version"
require "googlemaps/services/util"
require "net/http"
require "json"


module GoogleMaps
  module Services
    $USER_AGENT = "GoogleMapsRubyClient/" + VERSION
    $DEFAULT_BASE_URL = "https://maps.googleapis.com"
    $RETRIABLE_STATUSES = [500, 503, 504]

    # Performs requests to the Google Maps API web services
    class GoogleClient
      include GoogleMaps::Services::Exceptions

      attr_accessor :key, :timeout, :client_id, :client_secret,
                    :channel, :retry_timeout, :requests_kwargs,
                    :queries_per_second, :sent_times

      def initialize(key=nil, client_id=nil, client_secret=nil, timeout=nil,
                     connect_timeout=nil, read_timeout=nil,retry_timeout=60, requests_kwargs=nil,
                     queries_per_second=10, channel=nil)
        if !key && !(client_secret && client_id)
          raise StandardError, "Must provide API key or enterprise credentials when creationg client."
        end

        if key && !key.start_with?("AIza")
          raise StandardError, "Invalid API key provided."
        end

        if channel
          if !client_id
            raise StandardError, "The channel argument must be used with a client ID."
          end

          if !/^[a-zA-Z0-9._-]*$/.match(channel)
            raise StandardError, "The channel argument must be an ASCII alphanumeric string. The period (.), underscore (_) and hyphen (-) characters are allowed."
          end
        end

        self.key = key

        if timeout && (connect_timeout || read_timeout)
          raise StandardError, "Specify either timeout, or connect_timeout and read_timeout."
        end

        if connect_timeout && read_timeout
          self.timeout = {
            :connect_timeout => connect_timeout,
            :read_timeout => read_timeout
          }
        else
          self.timeout = timeout
        end

        self.client_id = client_id
        self.client_secret = client_secret
        self.channel = channel
        self.retry_timeout = retry_timeout
        self.requests_kwargs = requests_kwargs || {}
        self.requests_kwargs.merge!({
                                      :headers => {"User-Agent" => $USER_AGENT},
                                      :timeout => self.timeout,
                                      :verify => true
                                    })

        self.queries_per_second = queries_per_second
        self.sent_times = Array.new
      end

      # Performs HTTP GET request with credentials, returning the body as JSON
      def get(url, params, first_request_time=nil, retry_counter=nil, base_url=$DEFAULT_BASE_URL,
              accepts_clientid=true, extract_body=nil, requests_kwargs=nil)
        if !first_request_time
          first_request_time = Util.current_time
        end

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
          sleep(delay_seconds * (random.random() + 0.5))
        end

        authed_url = generate_auth_url(url, params, accepts_clientid)

        # Default to the client-level self.requests_kwargs, with method-level
        # requests_kwargs arg overriding.
        requests_kwargs = self.requests_kwargs.merge(requests_kwargs || {})

        # Construct the Request URI
        uri = URI.parse(base_url + authed_url)
        puts "===> URI: #{uri}"
        puts "===> URI path: #{uri.path}"
        puts "===> URI host: #{uri.host}"
        puts "====> URI port: #{uri.port}"

        # Add request headers
        req = Net::HTTP::Get.new(uri.to_s)
        requests_kwargs[:headers].each { |header,value| req.add_field(header, value) }

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == "https")
        # get responses
        resp = http.request(req)

        # Handle response errors
        case resp
        when Net::HTTPRequestTimeOut
          raise Timeout
        #else
        #  raise TransportError, "HTTP GET request failed."
        end

        if $RETRIABLE_STATUSES.include? resp.code.to_i
          # Retry request
          self.get(url, params, first_request_time, retry_counter + 1,
                   base_url, accepts_clientid, extract_body)
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
            result = extract_body(resp)
          else
            result = get_body(resp)
          end
          self.sent_times.push(Util.current_time)
          return result
        rescue RetriableRequest
          # retry request
          return self.get(url, params, first_request_time, retry_counter + 1,
                          base_url, accepts_clientid, extract_body)
        end
      end

      def get_body(resp)
        puts "Response code ==> #{resp.code}"
        if resp.code.to_i != 200
          raise HTTPError.new(resp.code)
        end

        puts "Response ==> #{resp.body}"

        body = JSON.parse(resp.body)

        api_status = body["status"]
        if api_status == "OK" || api_status == "ZERO_RESULTS"
          return body
        end

        if api_status == "OVER_QUERY_LIMIT"
          raise RetriableRequest
        end

        if body.key?("error_message")
          raise APIError.new(api_status), body["error_message"]
        else
          raise APIError.new(api_status)
        end
      end

      def generate_auth_url(path, params={}, accepts_clientid)
        if accepts_clientid && self.client_id && self.client_secret
          if self.channel
            params["channel"] = self.channel
          end
          params["client"] = self.client_id

          path = [path, Util.urlencode_params(params)].join("?")
          sig = Util.sign_hmac(self.client_secret, path)
          return path + "&signature=" + sig
        end

        if self.key
          params["key"] = self.key
          return path + "?" + Util.urlencode_params(params)
        end

        raise StandardError, "Must provide API key for this API. It does not accept enterprise credentials."
      end

      private :get_body, :generate_auth_url
    end

  end
end
