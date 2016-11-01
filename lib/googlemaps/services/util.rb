require 'net/http'
require 'openssl'
require 'base64'
require 'date'
require 'erb'

module GoogleMaps
  module Services

    module HashDot
      def method_missing(meth, *args, &block)
        if has_key?(meth.to_s)
          self[meth.to_s]
        else
          raise NoMethodError, "undefined method #{meth} for #{self}"
        end
      end
    end

    # Performs Array boxing.
    class ArrayBox
      # Wrap its argument in an array unless it is already an array or (array-like).
      #
      # @param [Object] object Object to wrap.
      # @example Wrap any Object in a array
      #   ArrayBox.wrap(nil)       # []
      #   ArrayBox.wrap([1, 2, 3]) # [1, 2, 3]
      #   ArrayBox.wrap(1)         # [1]
      #
      # @return [Array] an array.
      def self.wrap(object)
        if object.nil?
          []
        elsif object.respond_to? :to_ary
          object.to_ary || [object]
        else
          [object]
        end
      end
    end

    # Set of utility methods.
    class Util
      # Returns the current time
      #
      # Rails extends the Time and DateTime objects, and includes the "current" property
      # for retrieving the time the Rails environment is set to (default = UTC), as opposed to
      # the server time (Could be anything).
      #
      # @return [Time] a new Time object for the current time.
      def self.current_time
        (Time.respond_to? :current) ? Time.current : Time.now
      end

      # Returns the current UTC time.
      #
      # @return [Time] a new Time object for the current UTC (GMT) time.
      def self.current_utctime
        (Time.respond_to? :current) ? Time.current.utc : Time.now.utc
      end

      # Returns the current time in unix format (seconds since unix epoch).
      #
      # @return [Integer] number of seconds since unix epoch.
      def self.current_unix_time
        current_time.to_i
      end

      # Returns a base64-encoded HMAC-SHA1 signature of a given string.
      #
      # @param [String] secret The key used for the signature, base64 encoded.
      # @param [String] payload The payload to sign.
      #
      # @return [String] a base64-encoded signature string.
      def self.sign_hmac(secret, payload)
        payload = payload.encode('ascii')
        secret = secret.encode('ascii')
        digest = OpenSSL::Digest.new('sha1')
        sig = OpenSSL::HMAC.digest(digest, Base64.urlsafe_decode64(secret), payload)
        return Base64.urlsafe_encode64(sig).encode('utf-8')
      end

      # URL encodes the parameters.
      #
      # @param [Hash] params The parameters.
      #
      # @return [String] URL-encoded string.
      def self.urlencode_params(params)
        URI.encode_www_form(params)
      end
    end

    # Converts Ruby types to string representations suitable for Google Maps API server.
    class Convert
      # Converts the value into a unix time (seconds since unix epoch).
      #
      # @param [Integer, Time, Date] val value to convert to unix time format.
      # @example converts value to unix time
      #   Convert.unix_time(1472809264)
      #   Convert.unix_time(Time.now)
      #   Convert.unix_time(Date.parse("2016-09-02"))
      #
      # @return [String] seconds since unix epoch.
      def self.unix_time(val)
        case val
        when Integer
          val.to_s
        when Time
          val.to_i.to_s
        when Date
          val.to_time.to_i.to_s
        else
          raise TypeError, "#{__method__.to_s} expected value to be Integer, Time or Date."
        end
      end

      # Converts a lat/lng value to a comma-separated string.
      #
      # @param [String, Hash] arg The lat/lng value.
      # @example Convert lat/lng value to comma-separated string
      #   Convert.to_latlng("45.458878,-39.56487")
      #   Convert.to_latlng("Brussels")
      #   Convert.to_latlng({ :lat => 45.458878, :lng => -39.56487 })
      #
      # @return [String] comma-separated string.
      def self.to_latlng(arg)
        case arg
        when String
          arg
        when Hash
          "#{self.format_float(arg[:lat])},#{self.format_float(arg[:lng])}"
        else
          raise TypeError, "#{__method__.to_s} expected location to be String or Hash."
        end
      end

      # Formats a float value to as short as possible.
      #
      # @param [Float] arg The lat or lng float.
      # @example Formats the lat or lng float
      #   Convert.format_float(45.1289700)
      #
      # @return [String] formatted value of lat or lng float
      def self.format_float(arg)
        arg.to_s.chomp('0').chomp('.')
      end

      # Joins an array of locations into a pipe separated string, handling
      # the various formats supported for lat/lng values.
      #
      # @param [Array] arg Array of locations.
      # @example Joins the locations array to pipe-separated string
      #   arr = [{ :lat => -33.987486, :lng => 151.217990}, "Brussels"]
      #   Convert.piped_location(arr) # '-33.987486,151.21799|Brussels'
      #
      # @return [String] pipe-separated string.
      def self.piped_location(arg)
        raise TypeError, "#{__method__.to_s} expected argument to be an Array." unless arg.instance_of? Array
        arg.map { |location| to_latlng(location) }.join('|')
      end

      # If arg is array-like, then joins it with sep
      #
      # @param [String] sep Separator string.
      # @param [Object] arg Object to coerce into an array.
      #
      # @return [String] a joined string.
      def self.join_array(sep, arg)
        ArrayBox.wrap(arg).join(sep)
      end

      # Converts a Hash of components to the format expect by the Google Maps API server.
      #
      # @param [Hash] arg The component filter.
      # @example Converts a components hash to server-friendly string
      #   c = {"country" => ["US", "BE"], "postal_code" => 7452}
      #   Convert.components(c) # 'country:BE|country:US|postal_code:7452'
      #
      # @return [String] Server-friendly string representation
      def self.components(arg)
        raise TypeError, "#{__method__.to_s} expected a Hash of components." unless arg.is_a? Hash

        arg.map { |c, val|
          ArrayBox.wrap(val).map {|elem| "#{c}:#{elem}"}.sort_by(&:downcase)
        }.join('|')
      end

      # Converts a lat/lng bounds to a comma- and pipe-separated string.
      #
      # @param [Hash] arg The bounds. A hash with two entries - "southwest" and "northeast".
      #
      # @example Converts lat/lng bounds to comma- and pipe-separated string
      #   sydney_bounds = {
      #     :northeast => { :lat => -33.4245981, :lng => 151.3426361 },
      #     :southwest => { :lat => -34.1692489, :lng => 150.502229 }
      #   }
      #   Convert.bounds(sydney_bounds) # '-34.169249,150.502229|-33.424598,151.342636'
      #
      # @return [String] comma- and pipe-separated string.
      def self.bounds(arg)
        raise TypeError, "#{__method__.to_s} expected a Hash of bounds." unless arg.is_a? Hash
        "#{to_latlng(arg[:southwest])}|#{to_latlng(arg[:northeast])}"
      end

      # Encodes an array of points into a polyline string.
      #
      # See the developer docs for a detailed description of this algorithm:
      # https://developers.google.com/maps/documentation/utilities/polylinealgorithm
      #
      # @param [Array] points Array of lat/lng hashes.
      #
      # @return [String] a polyline string.
      def self.encode_polyline(points)
        raise TypeError, "#{__method__.to_s} expected an Array of points." unless points.is_a? Array
        last_lat, last_lng = 0, 0
        result = ''
        points.each { |point|
          lat = (point[:lat] * 1e5).round.to_i
          lng = (point[:lng] * 1e5).round.to_i
          delta_lat = lat - last_lat
          delta_lng = lng - last_lng

          [delta_lat, delta_lng].each { |val|
            val = (val < 0) ? ~(val << 1) : (val << 1)
            while val >= 0x20
              result += ((0x20 | (val & 0x1f)) + 63).chr
              val >>= 5
            end
            result += (val + 63).chr
          }

          last_lat = lat
          last_lng = lng
        }
        result
      end

      # Decodes a Polyline string into an array of lat/lng hashes.
      #
      # See the developer docs for a detailed description of this algorithm:
      # https://developers.google.com/maps/documentation/utilities/polylinealgorithm
      #
      # @param [String] polyline An encoded polyline.
      #
      # @return [Array] an array of lat/lng hashes.
      def self.decode_polyline(polyline)
        raise TypeError, "#{__method__.to_s} expected an argument of type String." unless polyline.is_a? String
        points = Array.new
        index, lat, lng = 0, 0, 0

        while index < polyline.length
          result = 1
          shift = 0
          while true
            b = polyline[index].ord - 63 - 1
            index += 1
            result += (b << shift)
            shift += 5
            if b < 0x1f
              break
            end
          end
          lat += (result & 1) != 0 ? (~result >> 1) : (result >> 1)

          result = 1
          shift = 0
          while true
            b = polyline[index].ord - 63 - 1
            index += 1
            result += (b << shift)
            shift += 5
            if b < 0x1f
              break
            end
          end
          lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1)

          points.push({:lat => lat * 1e-5, :lng => lng * 1e-5})
        end
        points
      end

      # Returns the shortest representation of the given locations.
      #
      # The Elevation API limits requests to 2000 characters, and accepts
      # multiple locations either as pipe-delimited lat/lng values, or
      # an encoded polyline, so we determine which is shortest and use it.
      #
      # @param [Array] locations The lat/lng array.
      #
      # @return [String] shortest path.
      def self.shortest_path(locations)
        raise TypeError, "#{__method__.to_s} expected an Array of locations." unless locations.is_a? Array
        encoded = "enc:#{encode_polyline(locations)}"
        unencoded = piped_location(locations)
        encoded.length < unencoded.length ? encoded : unencoded
      end
    end

  end
end
