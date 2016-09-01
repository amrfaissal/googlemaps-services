require "googlemaps/services/util"

module GoogleMaps
  module Services

    class Places
      attr_accessor :client

      def initialize(client:)
        self.client = client
      end

      def search(query:, location: nil, radius: nil, language: nil,
                    min_price: nil, max_price: nil, open_now: false, type: nil,
                    page_token: nil)
        places_handler(url_part: "text", query: query, location: location,
                      radius: radius, language: language, min_price: min_price,
                      max_price: max_price, open_now: open_now, type: type,
                      page_token: token)
      end

      def nearby(location:, radius: nil, keyword: nil, language: nil,
                      min_price: nil, max_price: nil, name: nil, open_now: false,
                      rank_by: nil, type: nil, page_token: nil)
        if rank_by == "distance"
          if !(keyword || name || type)
            raise StandardError, "either a keyword, name or type arg is required when rank_by is set to distance."
          elsif radius
            raise StandardError, "radius cannot be specified when rank_by is set to distance."
          end
        end

        places_handler(url_part: "nearby", location: location,
                       radius: radius, keyword: keyword, language: language,
                       min_price: min_price, max_price: max_price, name: name,
                       open_now: open_now, rank_by: rank_by, type: type,
                       page_taken: page_taken)
      end

      def radar(location:, radius:, keyword: nil, min_price: nil,
                     max_price: nil, name: nil, open_now: false, type: nil)
        if !(keyword || name || type)
          raise StandardError, "either a keyword, name, or type arg is required."
        end

        places_handler(url_part: "radar", location: location, radius: radius,
                       keyword: keyword, min_price: min_price, max_price: max_price,
                       name: name, open_now: open_now, type: type)
      end

      def places_handler(url_part:, query: nil, location: nil, radius: nil,
                         keyword: nil, language: nil, min_price: 0, max_price: 4,
                         name: nil, open_now: false, rank_by: nil, type: nil,
                         page_token: nil)
        params = { "minprice" => min_price, "maxprice" => max_price }

        if query
          params["query"] = query
        end

        if location
          params["location"] = Convert.to_latlng(location)
        end

        if radius
          params["radius"] = radius
        end

        if keyword
          params["keyword"] = keyword
        end

        if language
          params["language"] = language
        end

        if name
          params["name"] = Convert.join_array(" ", name)
        end

        if open_now
          params["opennow"] = "true"
        end

        if rank_by
          params["rankby"] = rank_by
        end

        if type
          params["type"] = type
        end

        if page_token
          params["pagetoken"] = page_token
        end

        self.client.get("/maps/api/place/#{url_part}search/json", params)
      end


      # Comprehensive details for an individual place.
      def place_details(place_id:, language: nil)
        params = { "placeid" => place_id }
        if language
          params["language"] = language
        end

        self.client.get("/maps/api/place/details/json", params)
      end

      def download_photo(photo_reference:, max_width: nil, max_height: nil)
        if !(max_width || max_height)
          raise StandardError, "a max_width or max_height arg is required"
        end

        params = {"photoreference" => photo_reference}

        if max_width
          params["maxwidth"] = max_width
        end

        if max_height
          params["maxheight"] = max_height
        end

        # TODO: Stream response in chunks
      end


      def autocomplete(input_text:, offset: nil, location: nil, radius: nil,
                      language: nil, type: nil, components: nil)
        _autocomplete(url_part: "", input_text: input_text, offset: offset, location: location,
                     radius: radius, language: language, type: type, components: components)
      end

      def autocomplete_query(input_text:, offset: nil, location: nil, radius: nil,
                             language: nil)
        _autocomplete(url_part: "query", input_text: input_text, offset: offset,
                      location: location, radius: radius, language: language)
      end

      def _autocomplete(url_part:, input_text:, offset: nil, location: nil,
                       radius: nil, language: nil, type: nil, components: nil)
        params = { "input" => input_text }

        if offset
          params["offset"] = offset
        end

        if location
          params["location"] = Convert.to_latlng(location)
        end

        if radius
          params["radius"] = radius
        end

        if language
          params["language"] = language
        end

        if type
          params["type"] = type
        end

        if components
          params["components"] = Convert.components(components)
        end

        self.client.get("/maps/api/place/#{url_part}autocomplete/json", params)["predictions"]
      end

      private :places_handler, :_autocomplete
    end
  end
end
