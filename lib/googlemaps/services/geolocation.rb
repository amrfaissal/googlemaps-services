require 'googlemaps/services/global_constants'
require 'googlemaps/services/exceptions'
require 'json'

module GoogleMaps
  module Services

    # Performs requests to the Google Geolocation API.
    #
    # @example
    #   geolocation = GoogleMaps::Services::Geolocation.new(client)
    #   location = geolocation.query(home_mobile_country_code: "310",
    #                           home_mobile_network_code: "410",
    #                           radio_type: "gsm",
    #                           carrier: "Vodafone",
    #                           consider_ip: "true")
    #   # {"location"=>{"lat"=>51.021327, "lng"=>3.7070152}, "accuracy"=>2598.0}
    class Geolocation
      include GoogleMaps::Services::Exceptions

      # @return [Symbol] The HTTP client.
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      # The Google Maps Geolocation API returns a location and accuracy radius based on information about cell towers and given WiFi nodes.
      #
      # For more information, see: https://developers.google.com/maps/documentation/geolocation/intro
      #
      # @param [String] home_mobile_country_code The mobile country code (MCC) for the device's home network.
      # @param [String] home_mobile_network_code The mobile network code (MNC) for the device's home network.
      # @param [String] radio_type The mobile radio type. Supported values are lte, gsm, cdma, and wcdma.
      #                            While this field is optional, it should be included if a value is available,
      #                            for more accurate results.
      # @param [String] carrier The carrier name.
      # @param [TrueClass, FalseClass] consider_ip Specifies whether to fall back to IP geolocation if wifi and cell tower
      #                                            signals are not available. Note that the IP address in the request header
      #                                            may not be the IP of the device.
      # @param [Array] cell_towers The array of cell tower hashes.
      #                            See: https://developers.google.com/maps/documentation/geolocation/intro#cell_tower_object
      # @param [Array] wifi_access_points The array of WiFi access point hashes.
      #                                   See: https://developers.google.com/maps/documentation/geolocation/intro#wifi_access_point_object
      #
      # @return [HashMap] The location with accuracy radius.
      def query(home_mobile_country_code: nil, home_mobile_network_code: nil, radio_type: nil,
                carrier: nil, consider_ip: true, cell_towers: nil, wifi_access_points: nil)
        params = {}

        if home_mobile_country_code
          params["homeMobileCountryCode"] = home_mobile_country_code
        end

        if home_mobile_network_code
          params["homeMobileNetworkCode"] = home_mobile_network_code
        end

        if radio_type
          raise StandardError, "invalid radio type value." unless Constants::SUPPORTED_RADIO_TYPES.include? radio_type
          params["radioType"] = radio_type
        end

        if carrier
          params["carrier"] = carrier
        end

        params["considerIp"] = consider_ip unless consider_ip


        if cell_towers
          params["cellTowers"] = cell_towers
        end

        if wifi_access_points
          params["wifiAccessPoints"] = wifi_access_points
        end

        self.client.request(url: '/geolocation/v1/geolocate',
                            params: {},
                            base_url: Constants::GOOGLEAPIS_BASE_URL,
                            extract_body: lambda(&method(:_geolocation_extract)),
                            post_json: params)
      end

      # Extracts result from the Geolocation API HTTP response.
      #
      # @private
      #
      # @param [HTTP::Response] response HTTP response object.
      #
      # @return [Hash] The result as a Hash.
      def _geolocation_extract(response)
        status_code = response.code.to_i
        begin
          body = JSON.parse(response.body)
        rescue JSON::ParserError
          raise APIError.new(status_code), 'Received malformed response.'
        end

        if body.key?('error')
          raise APIError.new(status_code), body['error']['errors'][0]['reason']
        end

        if status_code != 200
          raise HTTPError.new(status_code)
        end
        body
      end

      private :_geolocation_extract
    end

  end
end
