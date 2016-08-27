require "googlemaps/services/util"

module GoogleMaps
  module Services
    $TRAVEL_MODES = ["driving", "walking", "bicycling", "transit"]

    class Directions
      attr_accessor :client, :params

      def initialize(client, origin, destination, mode=nil, waypoints=nil, alternatives=false, avoid=nil,
                     language=nil, units=nil, region=nil, departure_time=nil, arrival_time=nil, optimize_waypoints=false,
                     transit_mode=nil, transit_routing_preference=nil, traffic_model=nil)
        self.client = client

        self.params = {
          "origin" => Convert.to_latlng(origin),
          "destination" => Convert.to_latlng(destination)
        }

        if mode
          if !$TRAVEL_MODES.include? mode
            raise StandardError, "Invalid travel mode."
          end
          self.params["mode"] = mode
        end

        if waypoints
          waypoints = Convert.piped_location(waypoints)
          if optimize_waypoints
            waypoints = "optimize:true|" + waypoints
          end
          self.params["waypoints"] = waypoints
        end

        if alternatives
          self.params["alternatives"] = true
        end

        if avoid
          self.params["avoid"] = Convert.join_list("|", avoid)
        end

        if language
          self.params["language"] = language
        end

        if units
          self.params["units"] = units
        end

        if region
          self.params["region"] = region
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
          self.params["transit_mode"] = Convert.join_list("|", transit_mode)
        end

        if transit_routing_preference
          self.params["transit_routing_preference"] = transit_routing_preference
        end

        if traffic_model
          self.params["traffic_model"] = tra
        end
      end

      def get_response
        self.client.get("/maps/api/directions/json", self.params)["routes"]
      end
    end

  end
end
