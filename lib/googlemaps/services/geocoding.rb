require "googlemaps/services/util"


module GoogleMaps
  module Services

    # Performs requests to the Google Maps Geocoding API.
    #
    # @example
    #   geocode = GoogleMaps::Services::Geocode.new(client)
    #   result = geocode.query(address: "1600 Amphitheatre Parkway, Mountain View, CA")
    class Geocode
      # @return [Symbol] The HTTP client.
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      # Geocoding is the process of converting addresses (like "1600 Amphitheatre Parkway, Mountain View, CA")
      # into geographic coordinates (like latitude 37.423021 and longitude -122.083739), which you can use
      # to place markers or position the map.
      #
      # @param [String] address The address to geocode.
      # @param [Hash] components A component filter for which you wish to obtain a geocode.
      #                          E.g. {'administrative_area': 'TX','country': 'US'}
      # @param [Hash] bounds The bounding box of the viewport within which to bias geocode results more prominently.
      #                      The hash must have :northeast and :southwest keys.
      # @param [String] region The region code, specified as a ccTLD ("top-level domain") two-character value.
      # @param [String] language The language in which to return results.
      #
      # @return [String] Valid JSON or XML response.
      def query(address: nil, components: nil, bounds: nil, region: nil, language: nil)
        params = {}

        if address
          params["address"] = address
        end

        if components
          params["components"] = Convert.components(components)
        end

        if bounds
          params["bounds"] = Convert.bounds(bounds)
        end

        if region
          params["region"] = region
        end

        if language
          params["language"] = language
        end

        self.client.get(url: "/maps/api/geocode/json", params: params)["results"]
      end
    end

    # Performs requests to the Google Maps Geocoding API.
    #
    # @example
    #   reverse_geocode = GoogleMaps::Services::ReverseGeocode(client)
    #   result = reverse_geocode.query(latlng: {:lat => 52.520645, :lng => 13.409779}, language: "fr")
    class ReverseGeocode
      attr_accessor :client

      def initialize(client)
        self.client = client
      end

      # Reverse geocoding is the process of converting geographic coordinates into a human-readable address.
      #
      # @param [String, Hash] latlng The lat/lng value or place_id for which you wish to obtain the closest, human-readable address.
      # @param [Array] result_type One or more address types to restrict results to.
      # @param [Array] location_type One or more location types to restrict results to.
      # @param [String] language The language in which to return results.
      #
      # @return [String] Valid JSON or XML response.
      def query(latlng:, result_type: nil, location_type: nil, language: nil)
        # Check if latlng param is a place_id string.
        # 'place_id' strings do not contain commas; latlng strings do.
        if latlng.is_a?(String) && !latlng.include?("'")
          params = {"place_id" => latlng}
        else
          params = {"latlng" => Convert.to_latlng(latlng)}
        end

        if result_type
          params["result_type"] = Convert.join_array("|", result_type)
        end

        if location_type
          params["location_type"] = Convert.join_array("|", location_type)
        end

        if language
          params["language"] = language
        end

        self.client.get(url: "/maps/api/geocode/json", params: params)["results"]
      end
    end

  end
end
