require 'googlemaps/services/util'

module GoogleMaps
  module Services

    # Performs requests to the Google Street View Map API.
    #
    # @example Get the street view map image
    #   streetview = GoogleMaps::Services::StreetViewImage.new(client)
    #   map_img = streetview.query(size: {:length=>400, :width=>400}, location: "40.714728,-73.998672", heading: 151.78, pitch: -0.76)
    #   # {
    #   #   :url => "https://maps.googleapis.com/maps/api/streetview?size=400x400&location=40.714728%2C-73.998672&heading=151.78&pitch=-0.76",
    #   #   :mime_type => "image/jpeg",
    #   #   :image_data => "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHR..."
    #   # }
    class StreetViewImage

      # @return [Symbol] The HTTP client.
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      # Get the street view map image.
      #
      # @param [Hash] size the rectangular dimensions of the street view image.
      # @param [String, Hash] location The address or lat/lng value of the street view map.
      # @param [String] pano A specific panorama ID.
      # @param [Numeric] heading The compass heading of the camera. Accepted values are from 0 to 360.
      # @param [Numeric] fov The horizontal field of view of the image. It is expressed in degrees, with a maximum allowed value of 120.
      # @param [Numeric] pitch The up or down angle of the camera relative to the Street View vehicle.
      #                        Positive values angle the camera up (with 90 degrees indicating straight up).
      #                        Negative values angle the camera down (with -90 indicating straight down).
      #
      # @return [Hash] Hash with image URL, MIME type and its base64-encoded value.
      def query(size:, location: nil, pano: nil, heading: nil, fov: nil, pitch: nil)
        params = {
          'size' => Convert.rectangular_dimensions(size)
        }

        if location
          params['location'] = Convert.to_latlng(location)
        end

        if pano
          params['pano'] = pano
        end

        if location && pano
          raise StandardError, 'should not specify both location and panorama ID.'
        end

        if heading
          raise StandardError, 'invalid compass heading value.' unless (0..360).include? heading
          params['heading'] = heading
        end

        if fov
          raise StandardError, 'invalid field of view (fov) value.' unless (0..120).include? fov
          params['fov'] = fov
        end

        if pitch
          raise StandardError, 'invalid pitch value.' unless (-90..90).include? pitch
          params['pitch'] = pitch
        end

        self.client.request(url: "/maps/api/streetview", params: params)
      end
    end
  end
end
