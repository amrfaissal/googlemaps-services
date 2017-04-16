require 'googlemaps/services/util'

module GoogleMaps
  module Services

    # Performs requests to the Google Maps Elevation API.
    #
    # @example
    #   elevation = GoogleMaps::Services::Elevation.new(client)
    #   result = elevation.query(locations: [{:lat => 52.520645, :lng => 13.409779}, "Brussels"])
    class Elevation

      # @return [Symbol] The HTTP client.
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      # Provides elevation data for locations provided on the surface of the earth, including depth locations
      # on the ocean floor (which return negative values). Provides elevation data sampled along a path on
      # the surface of the earth.
      #
      # @param [Array] locations Array of lat/lng values from which to calculate elevation data.
      # @param [String, Array] path An encoded polyline string, or an Array of lat/lng values from which to calculate elevation data.
      # @param [Integer] samples The number of sample points along a path for which to return elevation data.
      #
      # @return [Array, Nokogiri::XML::NodeSet] Valid JSON or XML response.
      def query(locations: nil, path: nil, samples: 0)
        params = {}

        if locations
          params['locations'] = Convert.shortest_path(locations)
        end

        if path
          if path.instance_of? String
            path = "enc:#{path}"
          elsif path.instance_of? Array
            path = Convert.shortest_path(path)
          else
            raise TypeError, 'Path should be either a String or an Array.'
          end

          params = {'path' => path, 'samples' => samples }
        end

        if path && locations
          raise StandardError, 'Should not specify both path and locations.'
        end

        case self.client.response_format
        when :xml
          self.client.request(url: '/maps/api/elevation/xml', params: params).xpath('//result')
        when :json
          self.client.request(url: '/maps/api/elevation/json', params: params)['results']
        else
          raise StandardError, 'Unsupported response format. Should be either :json or :xml.'
        end
      end
    end

  end
end
