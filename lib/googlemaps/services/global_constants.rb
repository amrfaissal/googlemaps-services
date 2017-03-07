# coding: utf-8
require 'googlemaps/services/version'

# Global constants used across the library
#
# @since 1.3.5
module Constants
  # The User-Agent header
  USER_AGENT = 'GoogleMapsRubyClient/' + GoogleMaps::Services::VERSION

  # The default base URL for all requests
  DEFAULT_BASE_URL = 'https://maps.googleapis.com'

  # HTTP statuses that will trigger a retry request
  RETRIABLE_STATUSES = [500, 503, 504]

  # The supported transportation modes
  TRAVEL_MODES = %w(driving walking bicycling transit)

  # The features to avoid
  AVOID_FEATURES = %w(tolls highways ferries indoor)

  # The base URL for Roads API
  ROADS_BASE_URL = 'https://roads.googleapis.com'

  # The supported scale values
  ALLOWED_SCALES = [2, 4]

  # The supported image formats
  SUPPORTED_IMG_FORMATS = ["png32", "gif", "jpg", "jpg-baseline"]

  # The supported map types
  SUPPORTED_MAP_TYPES = ["satellite", "hybrid", "terrain"]
end
