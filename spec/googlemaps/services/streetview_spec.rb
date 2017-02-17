require 'googlemaps/services/client'
require 'googlemaps/services/streetview'

include GoogleMaps::Services

describe StreetViewImage do
  let (:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==') }
  let (:streetview) { StreetViewImage.new(client) }
  before {
    allow(client).to receive(:get).and_return({
                                                :url => "https://maps.googleapis.com/maps/api/streetview?size=640x400&location=40.714728%2C-73.998672&heading=151.78&pitch=-0.76",
                                                :mime_type => "image/jpeg",
                                                :image_data => "/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHR..."
                                              })
  }

  describe '#query' do
    context 'given missing size argument' do
      it 'raises an ArgumentError exception' do
        expect { streetview.query(location: "40.714728,-73.998672") }.to raise_error(ArgumentError)
      end
    end

    context 'given both location and panorama ID' do
      it 'raises a StandardError exception' do
        expect {
          streetview.query(size: {:length=>640,:width=>400}, location: "40.714728,-73.998672", pano: "some-panorama-ID")
        }.to raise_error(StandardError)
      end
    end

    context 'given an invalid heading value' do
      it 'raises a StandardError exception' do
        invalid_heading = 457.13
        expect {
          streetview.query(size: {:length=>640,:width=>400}, location: "40.714728,-73.998672", heading: invalid_heading)
        }.to raise_error(StandardError)
      end
    end

    context 'given an invalid field of vue (fov) value' do
      it 'raises a StandardError exception' do
        invalid_fov = 130
        expect {
          streetview.query(size: {:length=>640,:width=>400}, location: "40.714728,-73.998672", fov: invalid_fov)
        }.to raise_error(StandardError)
      end
    end

    context 'given an invalid pitch value' do
      it 'raises a StandardError exception' do
        invalid_pitch = -180
        expect {
          streetview.query(size: {:length=>640,:width=>400}, location: "40.714728,-73.998672", pitch: invalid_pitch)
        }.to raise_error(StandardError)
      end
    end

    context 'given the correct parameters' do
      it 'returns hash containing map image information' do
        expected_result = streetview.query(size: {:length => 640, :width => 400},
                                           location: "40.714728,-73.998672",
                                           fov: 95,
                                           pitch: -0.76,
                                           heading: 151.78)
        expect(expected_result.is_a? Hash).to eq(true)
        expect(expected_result.empty?).to eq(false)
      end
    end
  end
end
