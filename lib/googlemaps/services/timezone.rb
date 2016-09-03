require "googlemaps/services/util"

module GoogleMaps
  module Services

    # Performs requests to the Google Maps Timezone API.
    #
    # @example
    #   timezone = GoogleMaps::Services::Timezone(client)
    #   result = timezone.query(location: "38.908133,-77.047119")
    class Timezone
      # @return [Symbol] The HTTP client.
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      # Get time zone for a location on the earth, as well as that location's time offset from UTC.
      #
      # @param [String, Hash] location The lat/lng value representing the location to look up.
      # @param [Integer, Time, Date] timestamp Specifies the desired time as seconds since midnight, January 1, 1970 UTC.
      #                                        The Time Zone API uses the timestamp to determine whether or not Daylight Savings should be applied.
      #                                        Times before 1970 can be expressed as negative values. Optional. Defaults to Util.current_utctime.
      # @param [String] language The language in which to return results.
      #
      # @return [Hash] Valid JSON or XML response.
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
