require "googlemaps/services/util"

module GoogleMaps
  module Services
    $TRAVEL_MODES = ["driving", "walking", "bicycling", "transit"]

    class Directions
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      def query(origin:, destination:, mode: nil, waypoints: nil, alternatives: false,
                avoid: nil, language: nil, units: nil, region: nil, departure_time: nil,
                arrival_time: nil, optimize_waypoints: false, transit_mode: nil,
                transit_routing_preference: nil, traffic_model: nil)
        params = {
          "origin" => Convert.to_latlng(origin),
          "destination" => Convert.to_latlng(destination)
        }

        if mode
          if !$TRAVEL_MODES.include? mode
            raise StandardError, "invalid travel mode."
          end
          params["mode"] = mode
        end

        if waypoints
          waypoints = Convert.piped_location(waypoints)
          if optimize_waypoints
            waypoints = "optimize:true|" + waypoints
          end
          params["waypoints"] = waypoints
        end

        if alternatives
          params["alternatives"] = true
        end

        if avoid
          params["avoid"] = Convert.join_array("|", avoid)
        end

        if language
          params["language"] = language
        end

        if units
          params["units"] = units
        end

        if region
          params["region"] = region
        end

        if departure_time
          params["departure_time"] = Convert.unix_time(departure_time)
        end

        if arrival_time
          params["arrival_time"] = Convert.unix_time(arrival_time)
        end

        if departure_time && arrival_time
          raise StandardError, "should not specify both departure_time and arrival_time."
        end

        if transit_mode
          params["transit_mode"] = Convert.join_array("|", transit_mode)
        end

        if transit_routing_preference
          params["transit_routing_preference"] = transit_routing_preference
        end

        if traffic_model
          params["traffic_model"] = traffic_model
        end

        self.client.get(url: "/maps/api/directions/json", params: params)["routes"]
      end
    end

  end
end
