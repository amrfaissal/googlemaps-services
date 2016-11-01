require 'googlemaps/services/places'
require 'googlemaps/services/client'

include GoogleMaps::Services

describe Places do
  let (:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==') }
  let (:places) { Places.new(client) }
  before (:each) {
    allow(places).to receive(:_places).and_return({})
    allow(client).to receive(:get).and_return({})
    allow(places).to receive(:_autocomplete).and_return([])
  }

  describe '#search' do
    it 'returns search results' do
      expect(places.search(query: 'Some place')).to eq({})
    end
  end

  describe '#nearby' do
    it 'returns nearby search results' do
      expect(places.nearby(location: {:lat => 50.8503, :lng => 4.3517})).to eq({})
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

    context 'given a keyword, type or name' do
      it 'returns radar search results' do
        expect(places.radar(location: {:lat => 50.8503, :lng => 4.3517}, radius: 10, name: 'Brussels')).to eq({})
      end
    end
  end

  describe '#place_details' do
    it 'returns details for an individual place' do
      expect(places.place_details(place_id: 'ChIJZ2jHc-2kw0cRpwJzeGY6i8E')).to eq({})
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
        allow(client).to receive(:get).and_return(expected)
        photo_ref = 'CnRvAAAAwMpdHeWlXl-lH0vp7lez4znKPIWSWvgvZFISdKx45AwJVP1Qp37YOrH7sqHMJ8C-vBDC546decipPHchJhHZL94RcTUfPa1jWzo-rSHaTlbNtjh-N68RkcToUCuY9v2HNpo5mziqkir37WU    8FJEqVBIQ4k938TI3e7bf8xq-uwDZcxoUbO_ZJzPxremiQurAYzCTwRhE_V0'
        expect(places.place_photo(photo_reference: photo_ref, max_width: 400)).to eq(expected)
      end
    end
  end

  describe '#autocomplete' do
    it 'returns an array of place predictions given a search string' do
      expect(places.autocomplete(input_text: 'Brussels')).to eq([])
    end
  end

  describe '#autocomplete_query' do
    it 'returns an array of place predictions given a search query' do
      expect(places.autocomplete_query(input_text: 'pizza near Brussels')).to eq([])
    end
  end
end
