require 'googlemaps/services/places'
require 'googlemaps/services/client'

include GoogleMaps::Services

describe Places do
  let (:client) {GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==')}
  let (:places) {Places.new(client)}
  before {
    allow(client).to receive(:request).and_return({})
  }

  describe '#search' do
    it 'returns search results' do
      expect(
          places.search(query: 'cafe',
                        location: "50.8449925,4.362961",
                        radius: 12.3,
                        language: "en",
                        min_price: 12,
                        max_price: 40,
                        open_now: true,
                        region: "BE",
                        page_token: "20")
      ).to eq({})
    end
  end

  describe '#nearby' do
    context 'given no location nor page_token' do
      it 'raises an error' do
        expect {places.nearby}.to raise_error(StandardError)
      end
    end

    context 'given rank by distance' do
      it 'raises a StandardError if keyword, name and type are nil' do
        expect {
          places.nearby(location: {:lat => 50.8503, :lng => 4.3517}, rank_by: "distance")
        }.to raise_error(StandardError)
      end

      it 'raises a StandardError if radius is not nil' do
        expect {
          places.nearby(location: {:lat => 50.8503, :lng => 4.3517},
                        rank_by: "distance",
                        type: "cafe",
                        radius: 500)
        }.to raise_error(StandardError)
      end
    end

    context 'given a certain location' do
      it 'returns nearby search results' do
        expect(
            places.nearby(location: {:lat => 50.8503, :lng => 4.3517},
                          radius: 500,
                          keyword: "cafe_late",
                          type: "cafe",
                          page_token: "20",
                          open_now: true,
                          language: "en",
                          rank_by: "type",
                          min_price: 2,
                          max_price: 6.5)
        ).to eq({})
      end
    end
  end

  describe '#radar' do
    context 'given no keyword, name or type' do
      it 'raises an error' do
        expect {
          places.radar(location: {:lat => 50.8503, :lng => 4.3517}, radius: 10)
        }.to raise_error(StandardError)
      end
    end

    context 'given a certain location' do
      it 'returns radar search results' do
        expect(places.radar(location: {:lat => 50.8503, :lng => 4.3517}, radius: 10, name: 'Brussels')).to eq({})
      end
    end
  end

  describe '#place_details' do
    it 'returns details for an individual place' do
      expect(places.place_details(place_id: 'ChIJZ2jHc-2kw0cRpwJzeGY6i8E', language: "en")).to eq({})
    end
  end

  describe '#place_photo' do
    context 'given no max_width or max_height' do
      it 'raises an error' do
        expect {
          photo_ref = 'CnRvAAAAwMpdHeWlXl-lH0vp7lez4znKPIWSWvgvZFISdKx45AwJVP1Qp37YOrH7sqHMJ8C-vBDC546decipPHchJhHZL94RcTUfPa1jWzo-rSHaTlbNtjh-N68RkcToUCuY9v2HNpo5mziqkir37WU8FJEqVBIQ4k938TI3e7bf8xq-uwDZcxoUbO_ZJzPxremiQurAYzCTwRhE_V0'
          places.search(photo_reference: photo_ref)
        }.to raise_error(StandardError)
      end
    end

    context 'given a photo reference with max_width or max_height' do
      it 'returns URL of the photo' do
        expected = 'https://lh4.googleusercontent.com/-1wzlVdxiW14/USSFZnhNqxI/AAAAAAAABGw/YpdANqaoGh4/s1600-w400/Google%2BSydney'
        allow(client).to receive(:request).and_return(expected)
        photo_ref = 'CnRvAAAAwMpdHeWlXl-lH0vp7lez4znKPIWSWvgvZFISdKx45AwJVP1Qp37YOrH7sqHMJ8C-vBDC546decipPHchJhHZL94RcTUfPa1jWzo-rSHaTlbNtjh-N68RkcToUCuY9v2HNpo5mziqkir37WU    8FJEqVBIQ4k938TI3e7bf8xq-uwDZcxoUbO_ZJzPxremiQurAYzCTwRhE_V0'
        expect(places.place_photo(photo_reference: photo_ref, max_width: 400, max_height: 600)).to eq(expected)
      end
    end
  end

  describe '#autocomplete' do
    context 'given unsupported response format' do
      it 'raises a StandardError exception' do
        client.response_format = :weird
        expect {
          places.autocomplete(input_text: 'Brussels',
                              offset: 6,
                              location: "50.9472095,4.0028986",
                              radius: 50)
        }.to raise_error(StandardError)
      end
    end

    context 'given unsupported components filter' do
      it 'raises an error' do
        expect {
          places.autocomplete(input_text: 'Brussels',
                              offset: 6,
                              location: '50.9472095,4.0028986',
                              radius: 50,
                              components: {'administrative_area' => 'TX', 'country' => 'US'})
        }.to raise_error {|error|
          expect(error.is_a?(StandardError)).to be(true)
          expect(error.to_s).to eql('Only country components are supported.')
        }
      end
    end

    context 'given a response format of value :json' do
      before {
        allow(client).to receive(:request).and_return({'predictions' => []})
      }
      it 'returns an array of predictions' do
        client.response_format = :json
        expect(
            places.autocomplete(input_text: 'Brussels',
                                offset: 6,
                                location: "50.9472095,4.0028986",
                                radius: 50,
                                language: "en",
                                types: "locality",
                                components: {'country' => 'BE'})
        ).to eq([])
      end
    end

    context 'given a response format of value :xml' do
      before {
        xml = <<-XML
                <AutocompletionResponse>
                  <status>OK</status>
                  <prediction>
                    <description>Paris, France</description>
                    <type>locality</type>
                    <type>political</type>
                    <type>geocode</type>
                    <place_id>ChIJD7fiBh9u5kcRYJSMaMOCCwQ</place_id>
                    <reference>CiQRAAAAJm0CiCHIC8C4GOjREdm3QtHYhMyFaUXKWAbGSaZImQ8SECnHAhpcuZaoSr0_TKfeHvwaFHMIq_BmUccTC4mt6EWVNMa67Xuq</reference>
                    <id>691b237b0322f28988f3ce03e321ff72a12167fd</id>
                    <term>
                      <value>Paris</value>
                      <offset>0</offset>
                    </term>
                    <term>
                      <value>France</value>
                      <offset>7</offset>
                    </term>
                    <matched_substring>
                    <offset>0</offset>
                    <length>5</length>
                    </matched_substring>
                  </prediction>
                </AutocompletionResponse>
        XML
        allow(client).to receive(:request).and_return(Nokogiri::XML(xml))
      }

      it 'returns an XML NodeSet of predictions' do
        client.response_format = :xml
        expected_val = places.autocomplete(input_text: 'Brussels',
                                           offset: 6,
                                           location: "50.9472095,4.0028986",
                                           radius: 50,
                                           language: "en",
                                           types: "(cities)",
                                           components: {'country' => 'BE'})

        expect(expected_val.is_a? Nokogiri::XML::NodeSet).to eq(true)
        expect(expected_val.empty?).to eq(false)
        expect(expected_val.size).to eq(1)
      end
    end
  end

  describe '#autocomplete_query' do
    it 'returns an array of place predictions given a search query' do
      allow(client).to receive(:request).and_return({'predictions' => []})
      expect(places.autocomplete_query(input_text: 'pizza near Brussels',
                                       offset: 6,
                                       location: "50.9472095,4.0028986",
                                       radius: 50,
                                       language: "en")).to eq([])
    end
  end
end
