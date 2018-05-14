require 'googlemaps/services/util'
require 'googlemaps/services/roads'
require 'googlemaps/services/client'
require 'googlemaps/services/exceptions'

include GoogleMaps::Services
include GoogleMaps::Services::Exceptions

describe Roads do
  let (:client) {GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==')}
  let (:roads) {Roads.new(client)}
  before (:each) {
    allow(client).to receive(:request).and_return({'snappedPoints' => [], 'speedLimits' => []})
  }

  describe '#snap_to_roads' do
    it 'returns an array of snapped points' do
      expect(roads.snap_to_roads(path: ['50.8503,4.3517'], interpolate: true)).to eq([])
    end
  end

  describe '#speed_limits' do
    it 'returns an array of speed limits' do
      expect(roads.speed_limits(place_ids: [])).to eq([])
    end
  end

  describe '#snapped_speed_limits' do
    it 'returns a hash with an array of speed limits and an array of snapped points' do
      expect(roads.snapped_speed_limits(path: [])).to eq({'snappedPoints' => [], 'speedLimits' => []})
    end
  end

  describe '#nearest_roads' do
    it 'returns an array of snapped points' do
      expect(roads.nearest_roads(points: [])).to eq([])
    end
  end

  describe '#_roads_extract' do
    context 'given a malformed JSON response' do
      let (:resp) {
        hash = {'body' => 'random response', 'code' => '200'}
        hash.extend(HashDot)
        hash
      }
      it 'raises an APIError exception' do
        expect {roads.send(:_roads_extract, resp)}.to raise_error(APIError)
      end
    end

    context 'given a valid JSON response with status RESOURCE_EXHAUSTED' do
      let (:resp) {
        hash = {
            'body' => '{"error":{"status":"RESOURCE_EXHAUSTED"}}',
            'code' => '200'
        }
        hash.extend(HashDot)
        hash
      }
      it 'raises an OverQueryLimit exception' do
        expect {roads.send(:_roads_extract, resp)}.to raise_error(OverQueryLimit)
      end
    end

    context 'given a valid JSON response containing an error' do
      let (:resp) {
        hash = {
            'body' => '{"error":{"status":"SOME_ERROR", "message":"resource drained"}}',
            'code' => '200'
        }
        hash.extend(HashDot)
        hash
      }
      it 'raises an APIError/HTTPError exception' do
        expect {roads.send(:_roads_extract, resp)}.to raise_error(APIError)
        resp['body'] = '{"error":{"status":"SOME_ERROR"}}'
        expect {roads.send(:_roads_extract, resp)}.to raise_error(APIError)
        resp['body'] = "{}"
        resp['code'] = 404
        expect {roads.send(:_roads_extract, resp)}.to raise_error(HTTPError)
      end
    end

    context 'given a valid JSON response' do
      let (:resp) {
        hash = {'body' => '{"results":[], "status":"OK"}', 'code' => '200'}
        hash.extend(HashDot)
        hash
      }
      it 'returns a hash containing the results' do
        expect(roads.send(:_roads_extract, resp)).to eq({"results" => [], "status" => "OK"})
      end
    end
  end
end
