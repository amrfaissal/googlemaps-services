require "googlemaps/services/util"

module GoogleMaps
  module Services

    $AVOIDS = ["tolls", "highways", "ferries"]

    class DistanceMatrix
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      def query(origins:, destinations:, mode: nil, language: nil, avoid: nil,
                units: nil, departure_time: nil, arrival_time: nil, transit_mode: nil,
                transit_routing_preference: nil, traffic_model: nil)
        params = {
          "origins" => Convert.piped_location(origins),
          "destinations" => Convert.piped_location(destinations)
        }

        if mode
          if !$TRAVEL_MODES.include? mode
            raise StandardError, "Invalid travel mode."
          end
          params["mode"] = mode
        end

        if language
          params["language"] = language
        end

        if avoid
          if !$AVOIDS.include? avoid
            raise StandardError, "Invalid route restriction."
          end
          params["avoid"] = avoid
        end

        if units
          params["units"] = units
        end

        if departure_time
          params["departure_time"] = Convert.unix_time(departure_time)
        end

        if arrival_time
          params["arrival_time"] = Convert.unix_time(arrival_time)
        end

        if departure_time && arrival_time
          raise StandardError, "Should not specify both departure_time and arrival_time."
        end

        if transit_mode
          params["transit_mode"] = Convert.join_arrayt("|", transit_mode)
        end

        if transit_routing_preference
          params["transit_routing_preference"] = transit_routing_preference
        end

        if traffic_model
          params["traffic_model"] = traffic_model
        end

        self.client.get(url: "/maps/api/distancematrix/json", params: params)
      end
    end
  end
end
