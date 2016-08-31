require "googlemaps/services/util"

module GoogleMaps
  module Services

    class Timezone
      attr_accessor :client, :params

      def initialize(client:, location:, timestamp: nil, language: nil)
        self.client = client

        self.params = {
          "location" => Convert.to_latlng(location),
          "timestamp" => Convert.unix_time(timestamp || Util.current_utctime)
        }

        if language
          self.params["language"] = language
        end
      end

      def get_response
        self.client.get("/maps/api/timezone/json", self.params)
      end
    end

  end
end
