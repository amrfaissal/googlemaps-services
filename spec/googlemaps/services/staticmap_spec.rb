require 'googlemaps/services/client'
require 'googlemaps/services/staticmap'

include GoogleMaps::Services

describe StaticMap do
  let (:staticmap) {
    client = GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==')
    StaticMap.new(client)
  }

  describe '#query' do
    context 'given missing size argument' do
      it 'raises an ArgumentError exception' do
        expect { staticmap.query(language: 'fr') }.to raise_error(ArgumentError)
      end
    end

    context 'given missing center, zoom and markers arguments' do
      it 'raises a StandardError exception' do
        expect { staticmap.query(size: '200x300') }.to raise_error(StandardError)
      end
    end

    context 'given the correct parameters' do
      it 'returns hash containing map image information' do
        expected_result = {
          :url => "https://maps.googleapis.com/maps/api/staticmap?size=640x400&center=50.8449925%2C4.362961&zoom=16&maptype=hybrid",
          :mime_type => "image/png",
          :image_data => "iVBORw0KGgoAAAANSUhEUgAAAoAAAAGQCAMAAAAJLSEXAAADAFBMVEU..."
        }
        allow(staticmap).to receive(:query).and_return(expected_result)
        expect(staticmap.query(size: {:length => 640, :width => 400},
                               center: "50.8449925,4.362961",
                               maptype: "hybrid",
                               zoom: 16)).to eq(expected_result)
      end
    end
  end
end
