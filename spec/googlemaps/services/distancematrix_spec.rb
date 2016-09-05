require 'googlemaps/services/client'
require 'googlemaps/services/distancematrix'

include GoogleMaps::Services

describe DistanceMatrix do
  let (:distancematrix) {
    client = GoogleClient.new(key: "AIzadGhpcyBpcyBhIGtleQ==")
    DistanceMatrix.new(client)
  }

  describe "#query" do
    it "returns distance matrix between origins and destinations" do
      allow(distancematrix).to receive(:query).and_return("{}")
      expect(distancematrix.query(origins: [], destinations: [])).to eq("{}")
    end
  end
end
