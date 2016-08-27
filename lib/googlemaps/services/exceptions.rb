module GoogleMaps
  module Services
    module Exceptions

      class APIError < StandardError
        attr_reader :status

        def initialize(status)
          self.status = status
        end
      end

      class TransportError < StandardError
      end

      class HTTPError < TransportError
        attr_accessor :status_code

        def initialize(status_code)
          self.status_code = status_code
        end

        def to_s
          "HTTP Error: #{self.status_code}"
        end
      end

      class Timeout < Exception
        def to_s
          "The request timed out."
        end
      end

      class RetriableRequest < Exception
      end

    end
  end
end
