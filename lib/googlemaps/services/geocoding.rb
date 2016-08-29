require "googlemaps/services/util"


module GoogleMaps
  module Services

    class Geocode
      attr_accessor :client, :params

      def initialize(client, address=nil, components=nil, bounds=nil, region=nil, language=nil)
        self.client = client

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

      def initialize(client, latlng, result_type=nil, location_type=nil, language=nil)

      end
    end

  end
end
