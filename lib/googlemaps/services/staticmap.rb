require 'googlemaps/services/util'

module GoogleMaps
  module Services

    # Performs requests to the Google Static Map API.
    #
    # TODO: Add example
    class StaticMap

      # @return [Symbol] The HTTP client.
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      def query(size:, center: nil, zoom: nil, scale: nil, format: nil,
                maptype: nil, language: nil, region: nil, markers: nil,
                path: nil, visible: nil, style: nil)
        params = { 'size' => size }

        unless (center && zoom) || markers
          raise StandardError, "both center and zoom are required if markers not present"
        end

        if center
          params['center'] = Convert.to_latlng(center)
        end

        if zoom
          params['zoom'] = zoom
        end

        if scale
          params['scale'] = scale
        end

        # TODO: validate the format and align with the supported formats
        if format
          params['format'] = format
        end

        if maptype
          params['maptype'] = maptype
        end

        if language
          params['language'] = language
        end

        if region
          params['region'] = region
        end

        if markers
          params['markers'] = markers
        end

        if path
          params['path'] = path
        end

        if visible
          params['visible'] = visible
        end

        # TODO: Create wrapper around styling the map
        if style
          params['style'] = style
        end

        self.client.get(url: "/maps/api/staticmap", params: params)
      end

    end

  end
end
