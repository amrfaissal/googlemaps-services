$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
Dir['googlemaps/services/*.rb'].each { |file| require file }
