require 'googlemaps/services/client'
require 'googlemaps/services/geocoding'

include GoogleMaps::Services

client = GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==')

describe Geocode do
  let (:geocode) {
    geocode = Geocode.new(client)
  }

  it 'converts an address into geographic coordinates' do
    allow(geocode).to receive(:query).and_return({})
    expect(geocode.query(address: '1600 Amphitheatre Parkway, Mountain View, CA')).to eq({})
  end
end

describe ReverseGeocode do
  let (:reverse_geocode) {
    ReverseGeocode.new(client)
  }

  it 'converts geographic coordinates into human-readable address' do
    allow(reverse_geocode).to receive(:query).and_return('Some address')
    expect(reverse_geocode.query(latlng: '50.8503,4.3517')).to eq('Some address')
  end
end
