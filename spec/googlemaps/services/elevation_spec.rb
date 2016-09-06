require 'googlemaps/services/client'
require 'googlemaps/services/elevation'

include GoogleMaps::Services

describe Elevation do
  let (:elevation) {
    client = GoogleClient.new(key: "AIzadGhpcyBpcyBhIGtleQ==")
    Elevation.new(client)
  }

  describe "#query" do
    context "given both locations and path" do
      it "raises an error" do
        expect {
          elevation.query(locations: [], path: "polyline_str")
        }.to raise_error(StandardError)
      end
    end

    context "given an array of locations" do
      it "returns elevation data for given locations" do
        allow(elevation).to receive(:query).and_return([])
        expect(elevation.query(locations: [])).to eq([])
      end
    end
  end
end
