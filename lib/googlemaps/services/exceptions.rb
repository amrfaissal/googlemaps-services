module GoogleMaps
  module Services
    # Defines errors that are raised by the Google Maps client.
    #
    # @since 1.0.0
    module Exceptions

      # Represents an error raised by the remote API.
      class APIError < StandardError
        # @return [Symbol] The response status code.
        attr_accessor :status

        def initialize(status)
          self.status = status
        end
      end

      # Something went wrong while trying to execute the request.
      class TransportError < StandardError
      end

      # Represents an unexpected HTTP error.
      class HTTPError < TransportError
        # @return [Symbol] status_code The response status code.
        attr_accessor :status_code

        def initialize(status_code)
          self.status_code = status_code
        end

        # Returns the string representation of this error.
        #
        # @return [String] Human-readable error string.
        def to_s
          "HTTP Error: #{self.status_code}"
        end
      end

      # Represents a timeout error.
      class Timeout < Exception
        # Return the string representation of this error.
        #
        # @return [String] Human-readable error string.
        def to_s
          'The request timed out.'
        end
      end

      # Signifies that the request can be retried.
      class RetriableRequest < Exception
      end

      # Signifies that the request failed because the client exceeded its query rate limit.
      # Normally we treat this as a retriable condition, but we allow the calling code to specify
      # that these requests should not be retried.
      class OverQueryLimit < RetriableRequest
      end

    end
  end
end
