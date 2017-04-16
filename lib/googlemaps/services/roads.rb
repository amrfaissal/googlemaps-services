require 'googlemaps/services/global_constants'
require 'googlemaps/services/exceptions'
require 'googlemaps/services/util'
require 'json'

module GoogleMaps
  module Services

    # Performs requests to the Google Maps Roads API.
    class Roads
      include GoogleMaps::Services::Exceptions

      # @return [Symbol] the HTTP client.
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      # Snaps a path to the most likely roads travelled. Takes up to 100 GPS points collected along a route,
      # and returns a similar set of data with the points snapped to the most likely roads the vehicle was traveling along.
      #
      # @param [Array] path The path to be snapped.
      # @param [TrueClass, FalseClass] interpolate Whether to interpolate a path to include all points forming the full road-geometry.
      #                                            When true, additional interpolated points will also be returned, resulting in a path
      #                                            that smoothly follows the geometry of the road, even around corners and through tunnels.
      #                                            Interpolated paths may contain more points than the original path.
      #
      # @return [Array] Array of snapped points.
      def snap_to_roads(path:, interpolate: false)
        params = {'path' => Convert.piped_location(path) }

        if interpolate
          params['interpolate'] = 'true'
        end

        self.client.request(url: '/v1/snapToRoads', params: params, base_url: Constants::ROADS_BASE_URL,
                        accepts_clientid: false, extract_body: lambda(&method(:_roads_extract)))['snappedPoints']
      end

      # Returns the posted speed limit (in km/h) for given road segments.
      #
      # @param [Array] place_ids The Place ID of the road segment. Place IDs are returned by the snap_to_roads function.
      #                          You can pass up to 100 Place IDs.
      #
      # @return [Array] Array of speed limits.
      def speed_limits(place_ids:)
        raise StandardError, "#{__method__.to_s} expected an Array for place_ids." unless place_ids.is_a? Array

        params = {'placeId' => place_ids}

        self.client.request(url: '/v1/speedLimits', params: params, base_url: Constants::ROADS_BASE_URL,
                        accepts_clientid: false, extract_body: lambda(&method(:_roads_extract)))['speedLimits']
      end

      # Returns the posted speed limit (in km/h) for given road segments.
      # The provided points will first be snapped to the most likely roads the vehicle was traveling along.
      #
      # @param [Array] path The path of points to be snapped.
      #
      # @return [Hash] Hash with an array of speed limits and an array of the snapped points.
      def snapped_speed_limits(path:)
        params = {'path' => Convert.piped_location(path)}

        self.client.request(url: '/v1/speedLimits', params: params, base_url: Constants::ROADS_BASE_URL,
                        accepts_clientid: false, extract_body: lambda(&method(:_roads_extract)))
      end

      # Find the closest road segments for each point.
      # Takes up to 100 independent coordinates, and returns the closest road segment for each point.
      # The points passed do not need to be part of a continuous path.
      #
      # @param [Array] points The points for which the nearest road segments are to be located.
      #
      # @return [Array] An array of snapped points.
      def nearest_roads(points:)
        params = {'points' => Convert.piped_location(points)}

        self.client.request(url: '/v1/nearestRoads', params: params, base_url: Constants::ROADS_BASE_URL,
                        accepts_clientid: false, extract_body: lambda(&method(:_roads_extract)))['snappedPoints']
      end

      # Extracts result from the Roads API HTTP response.
      #
      # @private
      #
      # @param [HTTP::Response] resp HTTP response object.
      #
      # @return [Hash, Array] Valid JSON response.
      def _roads_extract(resp)
        status_code = resp.code.to_i
        begin
          body = JSON.parse(resp.body)
        rescue JSON::ParserError
          raise APIError.new(status_code), 'Received malformed response.'
        end

        if body.key?('error')
          error = body['error']
          status = error['status']

          if status == 'RESOURCE_EXHAUSTED'
            raise RetriableRequest
          end

          if error.respond_to?(:key?) && error.key?('message')
            raise APIError.new(status), error['message']
          else
            raise APIError.new(status)
          end
        end

        if status_code != 200
          raise HTTPError.new(status_code)
        end
        body
      end

      private :_roads_extract
    end

  end
end
