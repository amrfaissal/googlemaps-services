require 'http'
require 'googlemaps/services/client'
require 'googlemaps/services/exceptions'

include GoogleMaps::Services
include GoogleMaps::Services::Exceptions


describe GoogleClient do
  describe '#request' do
    context 'given no API key' do
      let (:client) { GoogleClient.new }
      it 'raises a StandardError exception' do
        expect { client.request(url: '/path/to/service', params: {}) }.to raise_error {|error|
          expect(error).to be_a(StandardError)
          expect(error.to_s).to eq('Must provide API key or enterprise credentials when creationg client.')
        }
      end
    end

    context "given an API key that does not start with 'AIza'" do
      let (:client) { GoogleClient.new(key: 'dGhpcyBpcyBhIGtleQ==') }
      it 'raises a StandardError exception' do
        expect { client.request(url: '/path/to/service', params: {}) }.to raise_error {|error|
          expect(error).to be_a(StandardError)
          expect(error.to_s).to eq('Invalid API key provided.')
        }
      end
    end

    context 'given a channel with no client ID' do
      let (:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==', channel: 'azBze_Ejj34.') }
      it 'raises a StandardError exception' do
        expect { client.request(url: '/path/to/service', params: {}) }.to raise_error {|error|
          expect(error).to be_a(StandardError)
          expect(error.to_s).to eq('The channel argument must be used with a client ID.')
        }
      end
    end

    context 'given a non-alphanumeric channel string' do
      let (:client) {
        GoogleClient.new(client_id: 'AIzadGhpcyBpc==', client_secret: 'yBhIGtleQ', channel: '+=er10)=')
      }
      it 'raises an error' do
        expect { client.request(url: '/path/to/services', params: {}) }.to raise_error {|error|
          expect(error).to be_a(StandardError)
          expect(error.to_s).to eq('The channel argument must be an ASCII alphanumeric string. The period (.), underscore (_) and hyphen (-) characters are allowed.')
        }
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

  describe '#get_map_image' do
    let (:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==') }

    context 'given a response with status code different than 200' do
      let (:resp) {
        hash = {'body' => '', 'code' => '400'}
        hash.extend(HashDot)
        hash
      }

      it 'raises an HTTPError' do
        expect { client.send(:get_map_image, resp) }.to raise_error(HTTPError) { |error|
          expect(error.to_s).to eq("HTTP Error: #{resp.code}")
        }
      end
    end

    context 'given a valid response status code' do
      let (:resp) {
        hash = {
          'code' => '200',
          'content_type' => {:mime_type => 'text/html', :charset=>'UTF-8'}.extend(HashDot),
          'body' => "<html><body><div>Hello World!</div></body></html>",
          'uri' => HTTP::URI.parse("https://google.be/")
        }
        hash.extend(HashDot)
        hash
      }

      it 'returns a hash with media information (URL, MIME type and Base64-encoded value)' do
        expect(client.send(:get_map_image, resp)).to eql({
          :url => 'https://google.be/',
          :mime_type => 'text/html',
          :image_data => 'PGh0bWw+PGJvZHk+PGRpdj5IZWxsbyBXb3JsZCE8L2Rpdj48L2JvZHk+PC9odG1sPg=='
        })
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

    context 'given an OK or ZERO_RESULTS status' do
      let (:resp) {
        hash = {'body' => '{"status": "OK", "response":[]}', 'code' => '200'}
        hash.extend(HashDot)
        hash
      }
      it 'returns the response JSON body' do
        response = client.send(:get_json_body, resp)
        expect(response.is_a? Hash).to eq(true)
        expect(response.empty?).to eq(false)
        expect(response["status"]).to eq("OK")
      end
    end

    context 'given an OVER_QUERY_LIMIT status' do
      let (:resp) {
        hash = {'body' => '{"status": "OVER_QUERY_LIMIT", "error_message": "daily quota reached"}', 'code' => '200'}
        hash.extend(HashDot)
        hash
      }
      it 'raises a RetriableRequest exception' do
        expect { client.send(:get_json_body, resp)}.to raise_error(RetriableRequest)
      end
    end

    context 'given an errored response' do
      let (:resp) {
        hash = {'body' => '{"status": "INVALID_REQUEST", "error_message": "something went wrong"}', 'code' => '200'}
        hash.extend(HashDot)
        hash
      }
      it 'raises an APIError exception' do
        expect { client.send(:get_json_body, resp) }.to raise_error(APIError, "something went wrong")
      end
    end
  end

  describe '#get_xml_body' do
    let (:client) { GoogleClient.new(key: 'AIzadGhpcyBpcyBhIGtleQ==', response_format: :xml) }

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

    context 'given an OK or ZERO_RESULTS status' do
      let (:resp) {
        hash = {'body' => '<Response><status>OK</status><result><type>establishment</type></result></Response>', 'code' => '200'}
        hash.extend(HashDot)
        hash
      }
      it 'returns the response XML body' do
        response = client.send(:get_xml_body, resp)
        expect(response.is_a? Nokogiri::XML::Document).to eq(true)
        expect(response.xpath("//Response/status").text).to eq("OK")
      end
    end

    context 'given an OVER_QUERY_LIMIT status' do
      let (:resp) {
        hash = {'body' => '<Response><status>OVER_QUERY_LIMIT</status><error_message>Daily quota reached</error_message></Response>', 'code' => '200'}
        hash.extend(HashDot)
        hash
      }
      it 'raises a RetriableRequest exception' do
        expect { client.send(:get_xml_body, resp)}.to raise_error(RetriableRequest)
      end
    end

    context 'given an errored response' do
      let (:resp) {
        hash = {'body' => '<Response><status>INVALID_REQUEST</status><error_message>something went wrong</error_message></Response>', 'code' => '200'}
        hash.extend(HashDot)
        hash
      }
      it 'raises an APIError exception' do
        expect { client.send(:get_xml_body, resp) }.to raise_error(APIError, "something went wrong")
      end
    end
  end

  describe '#generate_auth_url' do
    context 'given both client_id and client_secret' do
      let (:client) {
        GoogleClient.new(client_id: "104-rdqt7.apps.googleusercontent.com", client_secret: "UOjXRXBibmBCwTNQ2RZKCxn3", channel:"chan-y87z")
      }
      it 'returns an auth URL with encoded signature and parameters' do
        expect(
          client.send(:generate_auth_url, '/path/to/service', true)
        ).to eql("/path/to/service?channel=chan-y87z&client=104-rdqt7.apps.googleusercontent.com&signature=IsxUgkXqYS7c2nqYHwUONboD7VA=")
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

    context 'given no API key' do
      let (:client) { GoogleClient.new(key: nil) }
      it 'raises an error' do
        expect { client.send(:generate_auth_url, '/path/to/service', false) }.to raise_error(StandardError)
      end
    end
  end

end
