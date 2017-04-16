# coding: utf-8
require 'googlemaps/services/version'

# Global constants used across the library
#
# @since 1.3.5
module Constants
  # The User-Agent header
  USER_AGENT = 'GoogleMapsRubyClient/' + GoogleMaps::Services::VERSION

  # The default base URL for all Google Maps requests
  DEFAULT_BASE_URL = 'https://maps.googleapis.com'

  # The default base URL for all Google APIs requests
  GOOGLEAPIS_BASE_URL = 'https://www.googleapis.com'

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

  # The supported mobile radio types
  SUPPORTED_RADIO_TYPES = %w(lte gsm cdma wcdma)
end
