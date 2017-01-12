require 'googlemaps/services/util'

module GoogleMaps
  module Services
    TRAVEL_MODES = %w(driving walking bicycling transit)
    AVOID_FEATURES = %w(tolls highways ferries indoor)

    # Performs requests to the Google Maps Directions API.
    #
    # @example
    #   directions = GoogleMaps::Services::Directions.new(client)
    #   result = directions.query(origin: "Brussels", destination: {:lat => 52.520645, :lng => 13.409779})
    class Directions
      # @return [Symbol] The HTTP client.
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      # Get directions between an origin point and a destination point.
      #
      # @param [String, Hash] origin The address or lat/lng hash value from which to calculate directions
      # @param [String, Hash] destination The address or lat/lng value from which to calculate directions
      # @param [String] mode The mode of transport to use when calculating directions. One of "driving",
      #                       "walking", "bicycling" or "transit".
      # @param [Array] waypoints Specifies an array of waypoints. Waypoints alter a route by routing it through
      #                          the specified location(s). A location can be a String or a lat/lng hash.
      # @param [TrueClass, FalseClass] alternatives If true, more than one route may be returned in the response.
      # @param [Array] avoid Indicates that the calculated route(s) should avoid the indicated featues.
      # @param [String] language The language in which to return results.
      # @param [String] units Specifies the unit system to use when displaying results. "metric" or "imperial".
      # @param [String] region The region code, specified as a ccTLD (top-level domain - two character value).
      # @param [Integer, Time] departure_time Specifies the desired time of departure.
      # @param [Integer, Time] arrival_time Specifies the desired time of arrival for transit directions.
      #                                     Note: you cannot specify both departure_time and arrival_time.
      # @param [TrueClass, FalseClass] optimize_waypoints optimize the provided route by rearranging the waypoints in a more efficient order.
      # @param [Array] transit_mode Specifies one or more preferred modes of transit. This parameter may only be specified for requests where the mode is transit.
      #                             Valid values are "bus", "subway", "train", "tram", "rail".
      #                             "rail" is equivalent to ["train", "tram", "subway"].
      # @param [String] transit_routing_preference Specifies preferences for transit requests. Valid values are "less_walking" or "fewer_transfers".
      # @param [String] traffic_model Specifies the predictive travel time model to use. Valid values are "best_guess" or "optimistic" or "pessimistic".
      #                               The traffic_model parameter may only be specified for requests where the travel mode is driving, and where the
      #                               request includes a departure_time.
      #
      # @return [Array, Nokogiri::XML::NodeSet] Valid JSON or XML response.
      def query(origin:, destination:, mode: nil, waypoints: nil, alternatives: false,
                avoid: [], language: nil, units: nil, region: nil, departure_time: nil,
                arrival_time: nil, optimize_waypoints: false, transit_mode: nil,
                transit_routing_preference: nil, traffic_model: nil)
        params = {
            'origin' => Convert.to_latlng(origin),
            'destination' => Convert.to_latlng(destination)
        }

        if mode
          unless TRAVEL_MODES.include? mode
            raise StandardError, 'invalid travel mode.'
          end
          params['mode'] = mode
        end

        if waypoints
          waypoints = Convert.piped_location(waypoints)
          if optimize_waypoints
            waypoints = 'optimize:true|' + waypoints
          end
          params['waypoints'] = waypoints
        end

        if alternatives
          params['alternatives'] = true
        end

        if avoid
          unless ArrayBox.contains_all?(AVOID_FEATURES, avoid)
            raise StandardError, 'invalid avoid feature.'
          end
          params['avoid'] = Convert.join_array('|', avoid)
        end

        if language
          params['language'] = language
        end

        if units
          params['units'] = units
        end

        if region
          params['region'] = region
        end

        if departure_time
          params['departure_time'] = Convert.unix_time(departure_time)
        end

        if arrival_time
          params['arrival_time'] = Convert.unix_time(arrival_time)
        end

        if departure_time && arrival_time
          raise StandardError, 'should not specify both departure_time and arrival_time.'
        end

        if transit_mode
          params['transit_mode'] = Convert.join_array('|', transit_mode)
        end

        if transit_routing_preference
          params['transit_routing_preference'] = transit_routing_preference
        end

        if traffic_model
          params['traffic_model'] = traffic_model
        end

        case self.client.response_format
        when :xml
          self.client.get(url: '/maps/api/directions/xml', params: params).xpath('//route')
        when :json
          self.client.get(url: '/maps/api/directions/json', params: params)['routes']
        else
          raise StandardError, 'Unsupported response format. Should be either :json or :xml.'
        end
      end
    end

  end
end
