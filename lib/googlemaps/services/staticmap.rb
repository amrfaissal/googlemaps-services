require 'googlemaps/services/util'

module GoogleMaps
  module Services
    ALLOWED_SCALES = [2, 4]
    SUPPORTED_IMG_FORMATS = ["png32", "gif", "jpg", "jpg-baseline"]
    SUPPORTED_MAP_TYPES = ["satellite", "hybrid", "terrain"]

    # Performs requests to the Google Static Map API.
    #
    # @example Get static map image
    #   staticmap = GoogleMaps::Services::StaticMap.new(client)
    #   map_img = staticmap.query(size: {:length => 640, :width => 400},
    #                             center: "50.8449925,4.362961",
    #                             maptype: "hybrid",
    #                             zoom: 16)
    #   # {
    #   #     :url => "https://maps.googleapis.com/maps/api/staticmap?size=640x400&center=50.8449925%2C4.362961&zoom=16&maptype=hybrid",
    #   #     :mime_type => "image/png",
    #   #     :image_data => "iVBORw0KGgoAAAANSUhEUgAAAoAAAAGQCAMAAAAJLSEXAAADAFBMVEU..."
    #   # }
    class StaticMap

      # @return [Symbol] The HTTP client.
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      # Get the static map image.
      #
      # @param [Hash] size The rectangular dimensions of the map image.
      # @param [String, Hash] center The address or lat/lng value of the map's center.
      # @param [Integer] zoom The magnification level of the map.
      # @param [Integer] scale The scale of the map. This affects the number of pixels that are returned.
      # @param [String] format The format of the resulting image. Defaults to "png8" or "png".
      # @param [String] maptype The type of map to construct. Defaults to "roadmap".
      # @param [String] language The language to use for display of labels on map tiles.
      # @param [String] region The region code specified as a two-character ccTLD ('top-level domain') value.
      # @param [String, List] markers One or more markers to attach to the image at specified locations.
      def query(size:, center: nil, zoom: nil, scale: 1, format: "png", maptype: "roadmap",
                language: nil, region: nil, markers: nil,path: nil, visible: nil, style: nil)
        params = { 'size' => Convert.rectangular_dimensions(size) }

        unless (center && zoom) || markers
          raise StandardError, "both center and zoom are required if markers not present"
        end

        if center
          params['center'] = Convert.to_latlng(center)
        end

        if zoom
          params['zoom'] = zoom
        end

        if scale != 1
          unless ALLOWED_SCALES.include? scale
            raise StandardError, "invalid scale value."
          end
          params['scale'] = scale
        end

        if format != "png"
          unless SUPPORTED_IMG_FORMATS.include? format
            raise StandardError, "invalid image format."
          end
          params['format'] = format
        end

        if maptype != "roadmap"
          unless SUPPORTED_MAP_TYPES.include? maptype
            raise StandardError, "invalid maptype value."
          end
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

        if style
          params['style'] = style
        end

        self.client.get(url: "/maps/api/staticmap", params: params)
      end

    end

  end
end
