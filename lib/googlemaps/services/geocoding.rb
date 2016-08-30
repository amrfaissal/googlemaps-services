require "googlemaps/services/util"


module GoogleMaps
  module Services

    class Geocode
      attr_accessor :client, :params

      def initialize(client, address: nil, components: nil, bounds: nil, region: nil, language: nil)
        self.client = client
        self.params = {}

        if address
          self.params["address"] = address
        end

        if components
          self.params["components"] = Convert.components(components)
        end

        if bounds
          self.params["bounds"] = Convert.bounds(bounds)
        end

        if region
          self.params["region"] = region
        end

        if language
          self.params["language"] = language
        end
      end

      def get_response()
        self.client.get("/maps/api/geocode/json", self.params)["results"]
      end
    end

    class ReverseGeocode
      attr_accessor :client, :params

      def initialize(client, latlng:, result_type: nil, location_type: nil, language: nil)
        self.client = client

        # Check if latlng param is a place_id string.
        # 'place_id' strings do not contain commas; latlng strings do.
        if latlng.is_a?(String) && !latlng.include?("'")
          self.params = {"place_id" => latlng}
        else
          self.params = {"latlng" => Convert.to_latlng(latlng)}
        end

        if result_type
          self.params["result_type"] = Convert.join_array("|", result_type)
        end

        if location_type
          self.params["location_type"] = Convert.join_array("|", location_type)
        end

        if language
          self.params["language"] = language
        end
      end

      def get_response()
        self.client.get("/maps/api/geocode/json", self.params)["results"]
      end
    end

  end
end
