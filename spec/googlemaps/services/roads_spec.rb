require 'googlemaps/services/roads'
require 'googlemaps/services/client'

include GoogleMaps::Services

describe Roads do
  let (:client) { GoogleClient.new(key: "AIzadGhpcyBpcyBhIGtleQ==") }
  let (:roads) { Roads.new(client) }
  before (:each) {
    allow(client).to receive(:get).and_return({
      "snappedPoints" => [],
      "speedLimits" => []
    })
  }

  describe "#snap_to_roads" do
    it "returns an array of snapped points" do
      expect(roads.snap_to_roads(path: ["50.8503,4.3517"])).to eq([])
    end
  end

  describe "#speed_limits" do
    it "returns an array of speed limits" do
      expect(roads.speed_limits(place_ids: [])).to eq([])
    end
  end

  describe "#snapped_speed_limits" do
    it "returns a hash with an array of speed limits and an array of snapped points" do
      expect(roads.snapped_speed_limits(path: [])).to eq({ "snappedPoints" => [], "speedLimits" => [] })
    end
  end

  describe "#nearest_roads" do
    it "returns an array of snapped points" do
      expect(roads.nearest_roads(points: [])).to eq([])
    end
  end
end
