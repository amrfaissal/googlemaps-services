require 'googlemaps/services/client'
require 'googlemaps/services/directions'

include GoogleMaps::Services

describe Directions do
  let (:directions) {
    client = GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==')
    Directions.new(client)
  }

  describe '#query' do
    it 'returns directions between two points' do
      allow(directions).to receive(:query).and_return('{}')
      expect(directions.query(origin: '', destination: '')).to eq('{}')
    end
  end
end
