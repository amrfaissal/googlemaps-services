require 'nokogiri'
require 'googlemaps/services/util'
require 'googlemaps/services/client'
require 'googlemaps/services/directions'

include GoogleMaps::Services

describe Directions do
  let (:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==') }
  let (:directions) { Directions.new(client) }
  before {
    allow(client).to receive(:request).and_return({'routes' => []})
  }

  describe '#query' do
    context 'given invalid travel mode' do
      it 'raises a StandardError exception' do
        client.response_format = :json
        expect {
          directions.query(origin: 'Brussels',
            destination: {:lat => 52.520645, :lng => 13.409779},
            mode: "invalid_mode")
        }.to raise_error(StandardError)
      end
    end

    context 'given invalid feature to avoid' do
      it 'raises a StandardError exception' do
        expect {
          directions.query(origin: 'Brussels',
            destination: {:lat => 52.520645, :lng => 13.409779},
            avoid: ["unknown_feature"])
        }.to raise_error(StandardError)
      end
    end

    context 'given both departure_time and arrival_time' do
      it 'raises a StandardError exception' do
        expect {
          directions.query(origin: 'Brussels',
            destination: {:lat => 52.520645, :lng => 13.409779},
            departure_time: Util.current_unix_time,
            arrival_time: Util.current_unix_time + 10)
        }.to raise_error(StandardError)
      end
    end

    context 'given unsupported response format' do
      it 'raises a StandardError exception' do
        client.response_format = :weird
        expect {
          directions.query(origin: 'Brussels',
            destination: {:lat => 52.520645, :lng => 13.409779})
        }.to raise_error(StandardError)
      end
    end

    context 'given a response format of value :json' do
      it 'returns an array of routes' do
        client.response_format = :json
        expect(
          directions.query(origin: 'Brussels',
            destination: {:lat => 52.520645, :lng => 13.409779})
        ).to eq([])
      end
    end

    context 'given a response format of value :xml' do
      before {
        xml = "<route><summary>A2</summary><step>1</step></route>"
        allow(client).to receive(:request).and_return(Nokogiri::XML(xml))
      }
      it 'returns an XML NodeSet' do
        client.response_format = :xml
        expected_val = directions.query(origin: 'Brussels',
          destination: {:lat => 52.520645, :lng => 13.409779},
          mode: "driving",
          waypoints: ["Luik", "Eupen"],
          alternatives: true,
          optimize_waypoints: true,
          avoid: ["tolls"],
          region: "be",
          transit_mode: "train",
          transit_routing_preference: "fewer_transfers",
          language: "fr",
          units: "metric",
          traffic_model: "best_guess")

        expect(expected_val.is_a? Nokogiri::XML::NodeSet).to eq(true)
        expect(expected_val.empty?).to eq(false)
        expect(expected_val.size).to eq(1)
      end
    end
  end
end
