require "googlemaps/services/util"

module GoogleMaps
  module Services

    $AVOIDS = ["tolls", "highways", "ferries"]

    class DistanceMatrix
      attr_accessor :client, :params

      def initialize(client, origins, destinations, mode=nil, language=nil, avoid=nil, units=nil,
          departure_time=nil, arrival_time=nil, transit_mode=nil, transit_routing_preference=nil, traffic_model=nil)
          self.client = client

          self.params = {
            "origins" => Convert.piped_location(origins),
            "destinations" => Convert.piped_location(destinations)
          }

          if mode
            if !$TRAVEL_MODES.include? mode
              raise StandardError, "Invalid travel mode."
            end
            self.params["mode"] = mode
          end

          if language
            self.params["language"] = language
          end

          if avoid
            if !$AVOIDS.include? avoid
              raise StandardError, "Invalid route restriction."
            end
            self.params["avoid"] = avoid
          end

          if units
            self.params["units"] = units
          end

          if departure_time
            self.params["departure_time"] = Convert.unix_time(departure_time)
          end

          if arrival_time
            self.params["arrival_time"] = Convert.unix_time(arrival_time)
          end

          if departure_time && arrival_time
            raise StandardError, "Should not specify both departure_time and arrival_time."
          end

          if transit_mode
            self.params["transit_mode"] = Convert.join_arrayt("|", transit_mode)
          end

          if transit_routing_preference
            self.params["transit_routing_preference"] = transit_routing_preference
          end

          if traffic_model
            self.params["traffic_model"] = traffic_model
          end
      end

      def get_response
        self.client.get("/maps/api/distancematrix/json", self.params)
      end
    end
  end
end
