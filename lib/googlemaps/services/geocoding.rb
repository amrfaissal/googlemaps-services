require "googlemaps/services/util"


module GoogleMaps
  module Services

    class Geocode
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      def query(address: nil, components: nil, bounds: nil, region: nil, language: nil)
        params = {}

        if address
          params["address"] = address
        end

        if components
          params["components"] = Convert.components(components)
        end

        if bounds
          params["bounds"] = Convert.bounds(bounds)
        end

        if region
          params["region"] = region
        end

        if language
          params["language"] = language
        end

        self.client.get(url: "/maps/api/geocode/json", params: params)["results"]
      end
    end

    class ReverseGeocode
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      def query(latlng:, result_type: nil, location_type: nil, language: nil)
        # Check if latlng param is a place_id string.
        # 'place_id' strings do not contain commas; latlng strings do.
        if latlng.is_a?(String) && !latlng.include?("'")
          params = {"place_id" => latlng}
        else
          params = {"latlng" => Convert.to_latlng(latlng)}
        end

        if result_type
          params["result_type"] = Convert.join_array("|", result_type)
        end

        if location_type
          params["location_type"] = Convert.join_array("|", location_type)
        end

        if language
          params["language"] = language
        end

        self.client.get(url: "/maps/api/geocode/json", params: params)["results"]
      end
    end

  end
end
