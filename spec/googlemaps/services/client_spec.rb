require 'googlemaps/services/client'
require 'googlemaps/services/exceptions'

include GoogleMaps::Services
include GoogleMaps::Services::Exceptions


describe GoogleClient do

  describe '#get' do
    context 'given no API key' do
      let (:client) { GoogleClient.new(key: nil) }
      it 'raises an error' do
        expect { client.get(url: '/path/to/service', params: {}) }.to raise_error(StandardError)
      end
    end

    context "given an API key that does not start with 'AIza'" do
      let (:client) { GoogleClient.new(key: 'dGhpcyBpcyBhIGtleQ==') }
      it 'raises an error' do
        expect { client.get(url: '/path/to/service', params: {}) }.to raise_error(StandardError)
      end
    end

    context 'given a channel with no client ID' do
      let (:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==', channel: 'chan_attr') }
      it 'raises an error' do
        expect { client.get(url: '/path/to/service', params: {}) }.to raise_error(StandardError)
      end
    end

    context 'given a non-alphanumeric channel string' do
      let (:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==', channel: 'chan_attr') }
      it 'raises an error' do
        expect { client.get(url: '/path/to/services', params: {}) }.to raise_error(StandardError)
      end
    end

    context 'given a timeout with either connect_timeout or read_timeout' do
      let (:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==', timeout: 60, connect_timeout: 30) }
      it 'raises an error' do
        expect { client.get(url: '/path/to/services', params: {}) }.to raise_error(StandardError)
      end
    end
  end

  describe '#get_redirection_url' do
    let (:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==') }

    context 'given a response with status code different than 3XX' do
      let (:resp) {
        hash = {'body' => '', 'code' => '200'}
        hash.extend(HashDot)
        hash
      }

      it 'returns a nil value' do
        expect(client.send(:get_redirection_url, resp)).to eq(nil)
      end
    end

    context 'given a response with a valid status code' do
      let (:resp) {
        hash = {'body' => '', 'code' => '304', 'location' => 'https://google.be/'}
        hash.extend(HashDot)
        hash
      }

      it 'returns a redirection URL' do
        expect(client.send(:get_redirection_url, resp)).to eq('https://google.be/')
      end
    end
  end

  describe '#get_json_body' do
    let (:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==') }

    context 'given a response with status code different than 200' do
      let (:resp) {
        hash = {'body' => '{}', 'code' => '403'}
        hash.extend(HashDot)
        hash
      }
      it 'raises an HTTPError' do
        expect { client.send(:get_json_body, resp) }.to raise_error(HTTPError)
      end
    end

    context 'given a malformed JSON response' do
      let (:resp) {
        hash = {'body' => 'random response', 'code' => '200'}
        hash.extend(HashDot)
        hash
      }
      it 'raises an APIError' do
        expect { client.send(:get_json_body, resp) }.to raise_error(APIError)
      end
    end
  end

  describe '#get_xml_body' do
    let (:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==') }

    context 'given a response with status code different than 200' do
      let (:resp) {
        hash = {'body' => '<data></data>', 'code' => '403'}
        hash.extend(HashDot)
        hash
      }

      it 'raises an HTTPError' do
        expect { client.send(:get_xml_body, resp) }.to raise_error(HTTPError)
      end
    end

    context 'given a malformed XML response' do
      let (:resp) {
        hash = {'body' => 'random response', 'code' => '200'}
        hash.extend(HashDot)
        hash
      }
      it 'raises an APIError' do
        expect { client.send(:get_xml_body, resp) }.to raise_error(APIError)
      end
    end
  end

  describe '#generate_auth_url' do
    context 'given no API key' do
      let (:client) { GoogleClient.new(key: nil) }
      it 'raises an error' do
        expect { client.send(:generate_auth_url, '/path/to/service', false) }.to raise_error(StandardError)
      end
    end

    context 'given a path with parameters' do
      let (:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==') }
      it 'returns an auth URL with encoded key and parameters' do
        expect(
          client.send(:generate_auth_url, '/path/to/service', {'param1' => 'value'}, false)
        ).to eql('/path/to/service?param1=value&key=AIzadGhpcyBpcyBhIGtleQ%3D%3D')
      end
    end
  end

end
