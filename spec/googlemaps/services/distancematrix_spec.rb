require 'googlemaps/services/util'
require 'googlemaps/services/client'
require 'googlemaps/services/distancematrix'

include GoogleMaps::Services

describe DistanceMatrix do
  let (:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==') }
  let (:distancematrix) { DistanceMatrix.new(client) }
  let (:origins) { ["Brussels", "Bruges"] }
  let(:destinations) { ["Ghent"] }

  before {
    allow(client).to receive(:get).and_return({
      "destination_addresses"=>["Ghent, Belgium"],
      "origin_addresses"=>["Brussels, Belgium", "Bruges, Belgium"],
      "rows"=>[{"elements"=>[{"distance"=>{"text"=>"57.2 km", "value"=>57215},
                "duration"=>{"text"=>"54 mins", "value"=>3247}, "status"=>"OK"}]},
              {"elements"=>[{"distance"=>{"text"=>"49.1 km", "value"=>49129},
               "duration"=>{"text"=>"47 mins", "value"=>2801}, "status"=>"OK"}]}], "status"=>"OK"})
  }

  describe '#query' do
    context 'given an invalid travel mode' do
      it 'raises a StandardError exception' do
        expect {
          distancematrix.query(origins: origins, destinations: destinations, mode: "invalid")
        }.to raise_error(StandardError)
      end
    end

    context "given an invalid avoid parameter" do
      it 'raises a StandardError exception' do
        expect {
          distancematrix.query(origins: origins, destinations: destinations, avoid: "invalid")
        }.to raise_error(StandardError)
      end
    end

    context 'given both departure_time and arrival_time' do
      it 'raises a StandardError exception' do
        expect {
          distancematrix.query(origins: origins,
            destinations: destinations,
            departure_time: Util.current_unix_time,
            arrival_time: Util.current_unix_time + 100)
        }.to raise_error(StandardError)
      end
    end

    context 'given origins and destinations from which to calculate distance and time' do
      it 'returns a matrix of distances' do
        distance_matrix = distancematrix.query(origins: origins,
          destinations: destinations,
          mode: "driving",
          language: "en",
          avoid: "tolls",
          units: "metric",
          departure_time: Util.current_unix_time,
          transit_mode: "bus",
          transit_routing_preference: "fewer_transfers",
          traffic_model: "optimistic")

        expect(distance_matrix.instance_of? Hash).to eq(true)
        expect(distance_matrix.empty?).to eq(false)
        expect(distance_matrix.has_key? "rows").to eq(true)
      end
    end
  end
end
