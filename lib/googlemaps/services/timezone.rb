require "googlemaps/services/util"

module GoogleMaps
  module Services

    class Timezone
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      def query(location:, timestamp: nil, language: nil)
        params = {
          "location" => Convert.to_latlng(location),
          "timestamp" => Convert.unix_time(timestamp || Util.current_utctime)
        }

        if language
          params["language"] = language
        end

        self.client.get(url: "/maps/api/timezone/json", params: params)
      end
    end

  end
end
