require 'googlemaps/services/util'
require 'googlemaps/services/client'
require 'googlemaps/services/exceptions'
require 'googlemaps/services/geolocation'

include GoogleMaps::Services
include GoogleMaps::Services::Exceptions

describe Geolocation do
  let (:client) {GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==')}
  let (:geolocation) {Geolocation.new(client)}

  before {
    allow(client).to receive(:request).and_return({"location" => {"lat" => 51.021327, "lng" => 3.7070152}, "accuracy" => 2598.0})
  }

  describe '#query' do
    context 'given an invalid mobile radio type' do
      it 'raises a StandardError exception' do
        expect {
          geolocation.query(home_mobile_country_code: "310",
                            home_mobile_network_code: "410",
                            radio_type: "invalid_radio_type",
                            carrier: "Vodafone",
                            consider_ip: "true")
        }.to raise_error(StandardError)
      end
    end

    context 'given the correct parameters' do
      it 'returns the location with accuracy radius' do
        result = geolocation.query(home_mobile_country_code: "310",
                                   home_mobile_network_code: "410",
                                   radio_type: "gsm",
                                   carrier: "Vodafone",
                                   consider_ip: "true",
                                   cell_towers: [{
                                                     "cellId" => 42,
                                                     "locationAreaCode" => 415,
                                                     "mobileCountryCode" => 310,
                                                     "mobileNetworkCode" => 410,
                                                     "age" => 0,
                                                     "signalStrength" => -60,
                                                     "timingAdvance" => 15
                                                 }],
                                   wifi_access_points: [{
                                                            "macAddress" => "00:25:9c:cf:1c:ac",
                                                            "signalStrength" => -43,
                                                            "age" => 0,
                                                            "channel" => 11,
                                                            "signalToNoiseRatio" => 0
                                                        }])
        expect(result.is_a? Hash).to eq(true)
        expect(result.key? 'location').to eq(true)
        expect(result.key? 'accuracy').to eq(true)
      end
    end
  end

  describe '#_geolocation_extract' do
    context 'given a malformed JSON response' do
      let (:response) {
        hash = {"body" => "invalid_json", "code" => "200"}
        hash.extend(HashDot)
        hash
      }
      it 'raises an APIError exception' do
        expect {geolocation.send(:_geolocation_extract, response)}.to raise_error(APIError)
      end
    end

    context 'given a valid JSON response containing errors' do
      let (:response) {
        hash = {"body" => "{\"error\":{\"errors\":[{\"domain\":\"global\",\"reason\":\"parseError\",\"message\":\"Parse Error\"}],\"code\":400,\"message\":\"Parse Error\"}}", "code" => "400"}
        hash.extend(HashDot)
        hash
      }
      it 'raises an APIError exception' do
        expect {geolocation.send(:_geolocation_extract, response)}.to raise_error(APIError, "parseError")
      end
    end

    context 'given a valid request but no results returned' do
      let (:response) {
        hash = {"body" => "{}", "code" => "404"}
        hash.extend(HashDot)
        hash
      }
      it 'returns an empty response' do
        expect(geolocation.send(:_geolocation_extract, response)).to eq({})
      end
    end

    context 'given request exceeds query rate limit' do
      let (:response) {
        hash = {'body' => '{"status": "OVER_QUERY_LIMIT"}', 'code' => "403"}
        hash.extend(HashDot)
        hash
      }
      it 'raises OverQueryLimit exception' do
        expect {geolocation.send(:_geolocation_extract, response)}.to raise_error(OverQueryLimit)
      end
    end

    context 'given a valid JSON response' do
      let (:response) {
        hash = {'body' => "{\"location\":{\"lat\":51.021327, \"lng\":3.7070152}, \"accuracy\":2598.0}", 'code' => "200"}
        hash.extend(HashDot)
        hash
      }
      it 'returns a hash containing the result' do
        result = geolocation.send(:_geolocation_extract, response)
        expect(result.is_a? Hash).to eq(true)
        expect(result.key? "location").to eq(true)
        expect(result.key? "accuracy").to eq(true)
      end
    end
  end
end
