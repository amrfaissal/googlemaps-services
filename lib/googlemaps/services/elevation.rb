require "googlemaps/services/util"


module GoogleMaps
  module Services

    class Elevation
      attr_accessor :client, :params

      def initialize(client, locations: [], path: nil, samples: 0)
        self.client = client
        self.params = {}

        if path && locations
          raise StandardError, "Should not specify both path and locations."
        end

        if locations
          self.params["locations"] = Convert.shortest_path(locations)
        end

        if path
          if path.is_a? String
            path = "enc:#{path}"
          elsif path.is_a? Array
            path = Convert.shortest_path(path)
          else
            raise TypeError, "Path should be either a String or an Array."
          end

          self.params = { "path" => path, "samples" => samples }
        end
      end

      def get_response
        self.client.get("/maps/api/elevation/json", self.params)["results"]
      end
    end

  end
end
