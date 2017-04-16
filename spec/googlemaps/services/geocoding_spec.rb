require 'googlemaps/services/client'
require 'googlemaps/services/geocoding'

include GoogleMaps::Services

describe Geocode do
  let(:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==') }
  let (:geocode) { Geocode.new(client) }
  before {
    allow(client).to receive(:request).and_return({'results' => []})
  }

  context 'given an address with filters and bounds' do
    it 'returns geographic coordinates' do
      expect(
        geocode.query(address: '1600 Amphitheatre Parkway, Mountain View, CA',
                      components: {'administrative_area'=>'TX','country'=>'US'},
                      bounds: {
                                :northeast => {:lat=>"42.1282269", :lng=>"-87.7108162"},
                                :southwest => {:lat=>"42.0886089",:lng=>"-87.7708629"}
                              },
                      region: "US",
                      language: "en")).to eq([])
    end
  end

  context 'given unsupported response format' do
    it 'raises a StandardError exception' do
      client.response_format = :weird
      expect {
          geocode.query(address: '1600 Amphitheatre Parkway, Mountain View, CA')
      }.to raise_error(StandardError)
    end
  end

  context 'given a response format of value :json' do
    it 'returns an array of results' do
      client.response_format = :json
      expect(geocode.query(address: '1600 Amphitheatre Parkway, Mountain View, CA')).to eq([])
    end
  end

  context 'given a response format of value :xml' do
    before {
      xml = "<result></result>"
      allow(client).to receive(:request).and_return(Nokogiri::XML(xml))
      client.response_format = :xml
    }

    it 'returns an XML NodeSet' do
      expected_val = geocode.query(address: '1600 Amphitheatre Parkway, Mountain View, CA')
      expect(expected_val.is_a? Nokogiri::XML::NodeSet).to eq(true)
      expect(expected_val.empty?).to eq(false)
      expect(expected_val.size).to eq(1)
    end
  end
end

describe ReverseGeocode do
  let(:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==') }
  let (:reverse_geocode) { ReverseGeocode.new(client) }
  before {
    allow(client).to receive(:request).and_return({'results' => []})
  }

  context 'given a lat/lng value' do
    it 'returns the address components' do
      expect(reverse_geocode.query(latlng: '50.8503,4.3517',
                              result_type: ["establishment", "amusement_park"],
                              location_type: "point_of_interest",
                              language: "fr")).to eq([])
    end
  end

  context 'given a place_id' do
    it 'returns the address components' do
      expect(reverse_geocode.query(latlng: 'ChIJWZsQ7Ip9wUcR6wMXGIZSC-w',
                              result_type: ["establishment", "amusement_park"],
                              location_type: "point_of_interest",
                              language: "fr")).to eq([])
    end
  end

  context 'given unsupported response format' do
    it 'raises a StandardError exception' do
      client.response_format = :weird
      expect { reverse_geocode.query(latlng: '50.8503,4.3517') }.to raise_error(StandardError)
    end
  end

  context 'given a response format of value :json' do
    it 'returns an array of results' do
      client.response_format = :json
      expect(reverse_geocode.query(latlng: '50.8503,4.3517')).to eq([])
    end
  end

  context 'given a response format of value :xml' do
    before {
      xml = <<-XML
      <result>
        <type>amusement_park</type>
        <type>establishment</type>
        <type>point_of_interest</type>
        <formatted_address>Walibi Belgium, Boulevard de l'Europe 100, 1300 Wavre, Belgium</formatted_address>
      </result>
      XML
      allow(client).to receive(:request).and_return(Nokogiri::XML(xml))
      client.response_format = :xml
    }

    it 'returns an XML NodeSet' do
      expected_val = reverse_geocode.query(latlng: '50.8503,4.3517')
      expect(expected_val.is_a? Nokogiri::XML::NodeSet).to eq(true)
      expect(expected_val.empty?).to eq(false)
      expect(expected_val.size).to eq(1)
    end
  end
end
