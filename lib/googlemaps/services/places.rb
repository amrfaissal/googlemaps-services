require 'googlemaps/services/util'

module GoogleMaps
  module Services

    # Performs requests to the Google Places API.
    class Places
      # @return [Symbol] The HTTP client.
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      # Performs places search.
      #
      # @param [String] query The text string on which to search. E.g. "restaurant".
      # @param [String, Hash] location The lat/lng value for which you wish to obtain the closest, human-readable address.
      # @param [Integer] radius Distance in meters within which to bias results.
      # @param [String] language The language in which to return results.
      # @param [Integer] min_price Restricts results to only those places with no less than this price level. Valid values are in the range from 0 (most affordable) to 4 (most expensive).
      # @param [Integer] max_price Restricts results to only those places with no greater than this price level. Valid values are in the range from 0 (most affordable) to 4 (most expensive).
      # @param [TrueClass, FalseClass] open_now Return only those places that are open for business at the time the query is sent.
      # @param [String] type Restricts the results to places matching the specified type. The full list of supported types is available here: https://developers.google.com/places/supported_types
      # @param [String] region The region code, specified as a ccTLD (country code top-level domain) two-character value.
      # @param [String] page_token Token from a previous search that when provided will returns the next page of results for the same search.
      #
      # @return [Hash, Nokogiri::XML::Document] Valid JSON or XML response.
      def search(query:, location: nil, radius: nil, language: nil, min_price: nil,
                 max_price: nil, open_now: false, type: nil, region: nil, page_token: nil)
        _places(url_part: 'text', query: query, location: location, radius: radius,
                language: language, min_price: min_price, max_price: max_price,
                open_now: open_now, type: type, region: region, page_token: page_token)
      end

      # Performs nearby search for places.
      #
      # @param [String, Hash] location The lat/lng value for which you wish to obtain the closest, human-readable address.
      # @param [Integer] radius Distance in meters within which to bias results.
      # @param [String] keyword A term to be matched against all content that Google has indexed for this place.
      # @param [String] language The language in which to return results.
      # @param [Integer] min_price Restricts results to only those places with no less than this price level. Valid values are in the range from 0 (most affordable) to 4 (most expensive).
      # @param [Integer] max_price Restricts results to only those places with no greater than this price level. Valid values are in the range from 0 (most affordable) to 4 (most expensive).
      # @param [Array] name One or more terms to be matched against the names of places.
      # @param [TrueClass, FalseClass] open_now Return only those places that are open for business at the time the query is sent.
      # @param [String] rank_by Specifies the order in which results are listed. Possible values are: prominence (default), distance
      # @param [String] type Restricts the results to places matching the specified type. The full list of supported types is available here: https://developers.google.com/places/supported_types
      # @param [String] page_token Token from a previous search that when provided will returns the next page of results for the same search.
      #
      # @return [Hash, Nokogiri::XML::Document] Valid JSON or XML response.
      def nearby(location: nil, radius: nil, keyword: nil, language: nil, min_price: nil,
                 max_price: nil, name: nil, open_now: false, rank_by: nil, type: nil, page_token: nil)
        if !location && !page_token
          raise StandardError, 'either a location or page_token is required.'
        end
        if rank_by == 'distance'
          if !(keyword || name || type)
            raise StandardError, 'either a keyword, name or type arg is required when rank_by is set to distance.'
          elsif radius
            raise StandardError, 'radius cannot be specified when rank_by is set to distance.'
          end
        end

        _places(url_part: 'nearby', location: location, radius: radius, keyword: keyword, language: language,
                min_price: min_price, max_price: max_price, name: name, open_now: open_now, rank_by: rank_by,
                type: type, page_token: page_token)
      end

      # Performs radar search for places.
      #
      # @param [String, Hash] location The latitude/longitude value for which you wish to obtain the closest, human-readable address.
      # @param [Integer] radius Distance in meters within which to bias results.
      # @param [String] keyword A term to be matched against all content that Google has indexed for this place.
      # @param [Integer] min_price Restricts results to only those places with no less than this price level. Valid values are in the range from 0 (most affordable) to 4 (most expensive).
      # @param [Integer] max_price Restricts results to only those places with no greater than this price level. Valid values are in the range from 0 (most affordable) to 4 (most expensive).
      # @param [Array] name One or more terms to be matched against the names of places.
      # @param [TrueClass, FalseClass] open_now Return only those places that are open for business at the time the query is sent.
      # @param [String] type Restricts the results to places matching the specified type. The full list of supported types is available here: https://developers.google.com/places/supported_types
      #
      # @return [Hash, Nokogiri::XML::Document] Valid JSON or XML response.
      def radar(location:, radius:, keyword: nil, min_price: nil,
                max_price: nil, name: nil, open_now: false, type: nil)
        warn '[DEPRECATION] Places Radar is deprecated as of June 30, 2018. After that time, this feature will no longer be available.'
        raise StandardError, 'either a keyword, name, or type arg is required.' unless (keyword || name || type)

        _places(url_part: 'radar', location: location, radius: radius,
                keyword: keyword, min_price: min_price, max_price: max_price,
                name: name, open_now: open_now, type: type)
      end

      # Handler for "places", "places_nearby" and "places_radar" queries.
      # @private
      def _places(url_part:, query: nil, location: nil, radius: nil, keyword: nil, language: nil,
                  min_price: 0, max_price: 4, name: nil, open_now: false, rank_by: nil, type: nil,
                  region: nil, page_token: nil)
        params = {'minprice' => min_price, 'maxprice' => max_price}

        if query
          params['query'] = query
        end

        if location
          params['location'] = Convert.to_latlng(location)
        end

        if radius
          params['radius'] = radius
        end

        if keyword
          params['keyword'] = keyword
        end

        if language
          params['language'] = language
        end

        if name
          params['name'] = Convert.join_array(' ', name)
        end

        if open_now
          params['opennow'] = 'true'
        end

        if rank_by
          params['rankby'] = rank_by
        end

        if type
          params['type'] = type
        end

        if region
          params['region'] = region
        end

        if page_token
          params['pagetoken'] = page_token
        end

        self.client.request(url: "/maps/api/place/#{url_part}search/#{self.client.response_format}", params: params)
      end

      # Comprehensive details for an individual place.
      #
      # @param [String] place_id A textual identifier that uniquely identifies a place, returned from a Places search.
      # @param [String] language The language in which to return results.
      #
      # @return [Hash, Nokogiri::XML::Document] Valid JSON or XML response.
      def place_details(place_id:, language: nil)
        params = {'placeid' => place_id}
        if language
          params['language'] = language
        end

        self.client.request(url: "/maps/api/place/details/#{self.client.response_format}", params: params)
      end

      # Downloads a photo from the Places API.
      #
      # @param [String] photo_reference A string identifier that uniquely identifies a photo, as provided by either a Places search or Places detail request.
      # @param [Integer] max_width Specifies the maximum desired width, in pixels.
      # @param [Integer] max_height Specifies the maximum desired height, in pixels.
      #
      # @return [String] URL of the photo.
      def place_photo(photo_reference:, max_width: nil, max_height: nil)
        raise StandardError, 'a max_width or max_height arg is required' unless (max_width || max_height)

        params = {'photoreference' => photo_reference}

        if max_width
          params['maxwidth'] = max_width
        end

        if max_height
          params['maxheight'] = max_height
        end

        self.client.request(url: '/maps/api/place/photo', params: params)
      end

      # Returns Place predictions given a textual search string and optional geographic bounds.
      #
      # @param [String] input_text The text string on which to search.
      # @param [Integer] offset The position, in the input term, of the last character that the service uses to match predictions. For example, if the input is 'Google' and the offset is 3, the service will match on 'Goo'.
      # @param [String, Hash] location The latitude/longitude value for which you wish to obtain the closest, human-readable address.
      # @param [Integer] radius Distance in meters within which to bias results.
      # @param [String] language The language in which to return results.
      # @param [String] type Restricts the results to places matching the specified type. The full list of supported types is available here: https://developers.google.com/places/web-service/autocomplete#place_types
      # @param [Hash] components A grouping of places to which you would like to restrict your results. Currently, you can use components to filter by up to 5 countries for example: {'country': ['US', 'AU']}
      #
      # @return [Array, Nokogiri::XML::NodeSet] Array of predictions.
      def autocomplete(input_text:, offset: nil, location: nil, radius: nil, language: nil, type: nil, components: nil)
        _autocomplete(url_part: "", input_text: input_text, offset: offset, location: location,
                      radius: radius, language: language, type: type, components: components)
      end

      # Returns Place predictions given a textual search query, such as "pizza near Brussels", and optional geographic bounds.
      #
      # @param [String] input_text The text query on which to search.
      # @param [Integer] offset The position, in the input term, of the last character that the service uses to match predictions. For example, if the input is 'Google' and the offset is 3, the service will match on 'Goo'.
      # @param [String, Hash] location The latitude/longitude value for which you wish to obtain the closest, human-readable address.
      # @param [Integer] radius Distance in meters within which to bias results.
      # @param [String] language The language in which to return results.
      #
      # @return [Array, Nokogiri::XML::NodeSet] Array of predictions.
      def autocomplete_query(input_text:, offset: nil, location: nil, radius: nil, language: nil)
        _autocomplete(url_part: 'query', input_text: input_text, offset: offset,
                      location: location, radius: radius, language: language)
      end

      # Handler for "autocomplete" and "autocomplete_query" queries.
      # @private
      def _autocomplete(url_part:, input_text:, offset: nil, location: nil,
                        radius: nil, language: nil, type: nil, components: nil)
        params = {'input' => input_text}

        if offset
          params['offset'] = offset
        end

        if location
          params['location'] = Convert.to_latlng(location)
        end

        if radius
          params['radius'] = radius
        end

        if language
          params['language'] = language
        end

        if type
          params['type'] = type
        end

        if components
          if components.size != 1 || components.keys[0] != 'country'
            raise StandardError, 'Only country components are supported.'
          end
          params['components'] = Convert.components(components)
        end

        case self.client.response_format
        when :xml
          self.client
              .request(url: "/maps/api/place/#{url_part}autocomplete/xml", params: params)
              .xpath('//prediction')
        when :json
          self.client
              .request(url: "/maps/api/place/#{url_part}autocomplete/json", params: params)
              .fetch('predictions', [])
        else
          raise StandardError, 'Unsupported response format. Should be either :json or :xml.'
        end
      end

      private :_places, :_autocomplete
    end
  end
end
