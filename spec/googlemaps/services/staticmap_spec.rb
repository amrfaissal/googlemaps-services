require 'googlemaps/services/client'
require 'googlemaps/services/staticmap'

include GoogleMaps::Services

describe StaticMap do
  let (:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==') }
  let (:staticmap) { StaticMap.new(client) }
  before {
    allow(client).to receive(:request).and_return({
          :url => "https://maps.googleapis.com/maps/api/staticmap?size=640x400&center=50.8449925%2C4.362961&zoom=16&maptype=hybrid",
          :mime_type => "image/png",
          :image_data => "iVBORw0KGgoAAAANSUhEUgAAAoAAAAGQCAMAAAAJLSEXAAADAFBMVEU..."})
  }

  describe '#query' do
    context 'given missing size argument' do
      it 'raises an ArgumentError exception' do
        expect { staticmap.query(language: 'fr') }.to raise_error(ArgumentError)
      end
    end

    context 'given markers not present and missing zoom' do
      it 'raises a StandardError exception' do
        expect {
          staticmap.query(size: {:length=>640, :width=>400}, center: "50.8449925,4.362961")
        }.to raise_error(StandardError)
      end
    end

    context 'given an invalid scale value' do
      it 'raises a StandardError exception' do
        INVALID_SCALE = 3 # should be either: [1, 2, 4]
        expect {
          staticmap.query(size: {:length=>640, :width=>400},
            scale: INVALID_SCALE,
            center: "50.8449925,4.362961",
            zoom: 16)
        }.to raise_error(StandardError)
      end
    end

    context 'given an invalid image format' do
      it 'raises a StandardError exception' do
        expect {
          staticmap.query(size: {:length=>640, :width=>400},
            center: "50.8449925,4.362961",
            zoom: 16,
            scale: 3,
            format: "xxx")
        }.to raise_error(StandardError)
      end
    end

    context 'given an invalid Mape type' do
      it 'raises a StandardError exception' do
        expect {
          staticmap.query(size: {:length => 640, :width => 400},
            center: "50.8449925,4.362961",
            maptype: "invalid",
            scale: 2,
            zoom: 16)
          }.to raise_error(StandardError)
      end
    end

    context 'given the correct parameters' do
      it 'returns hash containing map image information' do
        expected_result = staticmap.query(size: {:length => 640, :width => 400},
          center: "50.8449925,4.362961",
          maptype: "hybrid",
          format: "gif",
          scale: 2,
          zoom: 16,
          language: "en",
          region: "be",
          markers: ["color:blue|50.8449925,4.362961"],
          path: "color:0x0000ff|weight:5|40.737102,-73.990318|40.749825,-73.987963",
          visible: ["50.8449925,4.362961"],
          style: "feature:landscape|element:geometry.fill|color:0x000000")
        expect(expected_result.is_a? Hash).to eq(true)
        expect(expected_result.empty?).to eq(false)
      end
    end
  end
end
