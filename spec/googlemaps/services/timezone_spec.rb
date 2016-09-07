require 'googlemaps/services/timezone'
require 'googlemaps/services/client'

include GoogleMaps::Services

describe Timezone do
  let (:client) { GoogleClient.new(key: "AIzadGhpcyBpcyBhIGtleQ==") }
  let (:timezone) { Timezone.new(client) }
  before {
    allow(client).to receive(:get).and_return({})
  }

  describe "#query" do
    it "returns the time zone for a location on earth" do
      expect(timezone.query(location: "50.8503,4.3517")).to eq({})
    end
  end
end
