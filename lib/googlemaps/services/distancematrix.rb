require "googlemaps/services/util"

module GoogleMaps
  module Services

    $AVOIDS = ["tolls", "highways", "ferries"]

    # Performs requests to the Google Maps Distance Matrix API.
    #
    # @example
    #   distancematrix = GoogleMaps::Services::DistanceMatrix(client)
    #   result = distancematrix.query(origins: ["Brussels", "Ghent"], destinations: ["Bruges"])
    class DistanceMatrix
      # @return [Symbol] the HTTP client.
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      # Gets travel distance and time for a matrix of origins and destinations.
      #
      # @param [Array] origins One or more locations and/or lat/lng values, from which to calculate distance and time.
      #                 If you pass an address as a string, the service will geocode the string and convert it to a lat/lng coordinate to calculate directions.
      # @param [Array] destinations One or more addresses and/or lat/lng values, to which to calculate distance and time.
      #                             If you pass an address as a string, the service will geocode the string and convert it to a lat/lng coordinate to calculate directions.
      # @param [String] mode Specifies the mode of transport to use when calculating directions. Valid values are "driving", "walking", "transit" or "bicycling".
      # @param [String] language The language in which to return results.
      # @param [String] avoid Indicates that the calculated route(s) should avoid the indicated features. Valid values are "tolls", "highways" or "ferries".
      # @param [String] units Specifies the unit system to use when displaying results. Valid values are "metric" or "imperial".
      # @param [Integer, Time, Date] departure_time Specifies the desired time of departure.
      # @param [Integer, Time, Date] arrival_time Specifies the desired time of arrival for transit directions. Note: you can't specify both departure_time and arrival_time.
      # @param [Array] transit_mode Specifies one or more preferred modes of transit. his parameter may only be specified for requests where the mode is transit.
      #                             Valid values are "bus", "subway", "train", "tram", "rail". "rail" is equivalent to ["train", "tram", "subway"].
      # @param [String] transit_routing_preference Specifies preferences for transit requests. Valid values are "less_walking" or "fewer_transfers".
      # @param [String] traffic_model Specifies the predictive travel time model to use. Valid values are "best_guess" or "optimistic" or "pessimistic".
      #                               The traffic_model parameter may only be specified for requests where the travel mode is driving, and where the request includes a departure_time.
      #
      # @return [Hash, Nokogiri::XML::Document] Matrix of distances.
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

        self.client.get(url: "/maps/api/distancematrix/#{self.client.response_format}", params: params).class
      end
    end
  end
end
