require 'googlemaps/services/util'
require 'googlemaps/services/client'
require 'googlemaps/services/elevation'

include GoogleMaps::Services

describe Elevation do
  let (:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==') }
  let (:elevation) { Elevation.new(client) }
  before {
    allow(client).to receive(:get).and_return({'results' => []})
  }

  describe '#query' do
    context 'given both locations and path' do
      it 'raises a StandardError exception' do
        expect { elevation.query(locations: [], path: 'polyline_str') }.to raise_error(StandardError)
      end
    end

    context 'given an array of locations' do
      it 'returns elevation data for the given locations' do
        expect(elevation.query(locations: [{:lat => 52.520645, :lng => 13.409779}])).to eq([])
      end
    end

    context 'given a path as an encoded polyline string' do
      it 'returns elevation data for the given path' do
        expect(elevation.query(path: "a}p_IcbzpA")).to eq([])
      end
    end

    context 'given a path as an array of lat/lng values' do
      it 'returns elevation data for the given path' do
        expect(elevation.query(path: [{:lat => 52.520645, :lng => 13.409779}])).to eq([])
      end
    end

    context 'given an invalid path type' do
      it 'raises a TypeError exception' do
        expect { elevation.query(path:{}) }.to raise_error(TypeError)
      end
    end

    context 'given unsupported response format' do
      it 'raises a StandardError exception' do
        client.response_format = :weird
        expect {
          elevation.query(locations: [{:lat => 52.520645, :lng => 13.409779}])
        }.to raise_error(StandardError)
      end
    end

    context 'given a response format of value :json' do
      it 'returns an array of results' do
        client.response_format = :json
        expect(elevation.query(locations: [{:lat => 52.520645, :lng => 13.409779}])).to eq([])
      end
    end

    context 'given a response format of value :xml' do
      before {
        xml = "<result></result>"
        allow(client).to receive(:get).and_return(Nokogiri::XML(xml))
        client.response_format = :xml
      }
      it 'returns an XML NodeSet' do
        expected_val = elevation.query(locations: [{:lat => 52.520645, :lng => 13.409779}])
        expect(expected_val.is_a? Nokogiri::XML::NodeSet).to eq(true)
        expect(expected_val.empty?).to eq(false)
        expect(expected_val.size).to eq(1)
      end
    end

  end
end
