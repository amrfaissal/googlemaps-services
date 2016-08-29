require "net/http"
require "openssl"
require "base64"
require "date"
require "erb"


module GoogleMaps
  module Services

    module ArrayExt
      def self.included base
        base.extend ClassMethods
      end

      module ClassMethods
        # Wrap its argument in an array unless it is already an array
        # or (array-like).
        #
        #     Array.wrap(nil)       -> []
        #     Array.wrap([1, 2, 3]) -> [1, 2, 3]
        #   Array.wrap(1)         -> [1]
        #
        def wrap(object)
          if object.nil?
            []
          elsif object.respond_to? :to_ary
            object.to_ary || [object]
          else
            [object]
          end
        end
      end
    end

    class Array
      include ArrayExt unless self.respond_to? :wrap
    end

    class Util
      def self.current_time
        # Returns the current time
        # NOTE: Rails extends the Time and DateTime objects, and includes the "current" property
        # for retrieving the time the Rails environment is set to (default = UTC), as opposed to
        # the server time (Could be anything).
        (Time.respond_to? :current) ? Time.current : Time.now
      end

      # Returns the current time in unix format (seconds since unix epoch)
      def self.current_unix_time
        current_time.to_i
      end

      # Returns a base64-encoded HMAC-SHA1 signature of a given string.
      def self.sign_hmac(secret, payload)
        payload = payload.encode('ascii')
        secret = secret.encode('ascii')
        digest = OpenSSL::Digest.new('sha1')
        sig = OpenSSL::HMAC.digest(digest, Base64.urlsafe_decode64(secret), payload)
        return Base64.urlsafe_encode64(sig).encode('utf-8')
      end

      def self.urlencode_params(params)
        URI.encode_www_form(params)
      end
    end

    class Convert
      # Converts the value into a unix time (seconds since unix epoch)
      def self.unix_time(val)
        if val.is_a? Integer
          val.to_s
        elsif val.is_a? Time
          val.to_i.to_s
        elsif val.is_a? Date
          val.to_time.to_i.to_s
        else
          raise TypeError, "#{__method__.to_s} expected value to be Integer, Time or Date."
        end
      end

      def self.to_latlng(arg)
        if arg.is_a? String
          arg
        elsif arg.is_a? Hash
          "#{self.format_float(arg[:lat])},#{self.format_float(arg[:lng])}"
        else
          raise TypeError,
                  "#{__method__.to_s} expected location to be String (e.g. 'Sydney') or Hash (e.g. {:lat => -33.8674869, :lng => 151.2069902})"
        end
      end

      # Formats a float value to as short as possible
      def self.format_float(arg)
        arg.to_s.chomp("0").chomp(".")
      end

      # Joins a list of locations into a pipe separated string, handling
      # the various formats supported for lat/lng values
      def self.piped_location(arg)
        raise TypeError, "You called #{__method__.to_s} without arg:Array needed." unless arg.is_a? Array
        arg.map { |location|
          if location.is_a? String
            location
          elsif location.is_a? Hash
            to_latlng(location)
          else
            raise TypeError, "#{__method__.to_s} expected location to be String or Hash."
          end
        }.join("|")
      end

      # If arg is array-like, then joins it with sep
      def self.join_array(sep, arg)
        Array.wrap(arg).join(sep)
      end

      # Converts a Hash of components to the format expect by
      # the Google Maps server.
      def self.components(arg)
        raise TypeError, "#{__method__.to_s} expected a Hash for components." unless arg.is_a? Hash

        arg.map { |c, val|
          Array.wrap(val).map {|elem| "#{c}:#{elem}"}
        }.join("|")
      end

      # Converts a lat/lng bounds to a comma- and pipe-separated string
      def self.bounds(arg)
        raise TypeError, "#{__method__.to_s} expected a Hash for components." unless arg.is_a? Hash
        "#{to_latlng(arg[:southwest])}|#{to_latlng(arg[:northeast])}"
      end



    end

  end
end
