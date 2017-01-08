require 'googlemaps/services/util'

include GoogleMaps::Services

describe HashDot do
  context 'given a hash with keys and values' do
    it 'accesses a key by method' do
      hash = { :key1 => 'value1', 'key2' => 'value2', :key3 => 'value3'}
      hash.extend(HashDot)
      expect(hash.key1).to eq('value1')
      expect(hash.key2).to eq('value2')
      expect(hash.key3).to eq('value3')
    end
  end

  context 'given an empty hash and trying to access a key by method' do
    it 'raises a NoMethodError exception' do
      hash = {}
      hash.extend(HashDot)
      expect { hash.key1 }.to raise_error(NoMethodError)
    end
  end
end

describe ArrayBox do
  describe '.wrap' do
    context 'given a nil object' do
      it 'returns an empty array' do
        expect(ArrayBox.wrap(nil)).to eql([])
      end
    end

    context 'given a plain old object' do
      it 'returns an array containing that object' do
        expect(ArrayBox.wrap(1)).to eql([1])
      end
    end
  end

  describe '.contains_all?' do
    it 'checks if one array contains all elements of another array' do
      target_arr = ["element1", "element2", "element3"]
      expect(ArrayBox.contains_all?(target_arr, ["element1"])).to eql(true)
    end
  end
end

describe Util do

  now = Time.parse('1969-07-20 20:17:40')
  before {
    allow(Time).to receive(:now) { now }
  }

  describe '.current_time' do
    it 'returns the current time' do
      expect(Util.current_time).to eql(now)
    end
  end

  describe '.current_unix_time' do
    it 'returns current time in unix format' do
      expect(Util.current_unix_time).to eql(-14186540)
    end
  end

  describe '.current_utctime' do
    it 'returns current UTC time' do
      expect(Util.current_utctime).to eql(now.utc)
    end
  end

  describe '.sign_hmac' do
    secret = 'AIzadGhpcyBpcyBhIGtleQ=='
    payload = 'This is a secret message'
    it 'returns base64-encoded HMAC-SHA1 signature of a given payload' do
      expect(Util.sign_hmac(secret, payload)).to eql('aHCS-FDYjWOqk85pMGOKv2gNprw=')
    end
  end

  describe '.urlencode_params' do
    params = {
        'origins' => 'Sydney',
        'destinations' => 'New York',
        'key' => 'AIzaBuyMirfbsiR91cw_JAD89Cwoocho4tZi7g'
    }
    expected = 'origins=Sydney&destinations=New+York&key=AIzaBuyMirfbsiR91cw_JAD89Cwoocho4tZi7g'
    it 'generates URL-encoded parameters' do
      expect(Util.urlencode_params(params)).to eql(expected)
    end
  end

end

describe Convert do

  describe '.unix_time' do
    context 'given value of type Integer' do
      expected = '1472318142'
      it 'returns unix time since epoch' do
        expect(Convert.unix_time(1472318142)).to eql(expected)
      end
    end

    context 'given value of type Time' do
      time = Time.parse('2016-08-27 19:15:42 +0200')
      expected = '1472318142'
      it 'returns unix time since epoch' do
        expect(Convert.unix_time(time)).to eql(expected)
      end
    end

    context 'given value of type Date' do
      date = Date.new(2016, 8, 27)
      expected = '1472248800'
      it 'returns unix time since epoch' do
        expect(Convert.unix_time(date)).to eql(expected)
      end
    end

    context 'given value of wrong type' do
      it 'raises a TypeError exception' do
        expect{
          Convert.unix_time({})
        }.to raise_error(TypeError)
      end
    end
  end

  describe '.to_latlng' do
    context 'given a location of type String' do
      it 'returns the location itself' do
        expect(Convert.to_latlng('Sydney')).to eql('Sydney')
      end
    end

    context 'given a location of type Hash' do
      it 'returns the location in comma-separated string' do
        expect(Convert.to_latlng({:lat => -33.865143, :lng => 151.209900})).to eql('-33.865143,151.2099')
      end
    end

    context 'given a location of wrong type' do
      it 'raises a TypeError exception' do
        expect { Convert.to_latlng([-33.865143, 151.2099]) }.to raise_error(TypeError)
      end
    end
  end

  describe '.format_float' do
    it 'formats a float value to as short as possible' do
      expect(Convert.format_float(151.209900)).to eql('151.2099')
    end
  end

  describe '.piped_location' do
    context 'given an argument of wrong type' do
      it 'raises a TypeError exception' do
        expect { Convert.piped_location({}) }.to raise_error(TypeError)
      end
    end

    context 'given an array of locations that are not a String or Hash' do
      it 'raises a TypeError exception' do
        expect {
          Convert.piped_location(['Sydney', [-33.865143, 151.2099]])
        }.to raise_error(TypeError)
      end
    end

    context 'given an array of locations of type String or Hash' do
      it 'returns a pipe separated string' do
        expect(
            Convert.piped_location(['Sydney', {:lat => -33.865143, :lng => 151.209900}])
        ).to eql('Sydney|-33.865143,151.2099')
      end
    end
  end

  describe '.join_array' do
    it 'joins the array with a separator' do
      expect(Convert.join_array(';', [1, 2, 3])).to eql('1;2;3')
    end
  end

  describe '.components' do
    context 'given an argument of wrong type' do
      it 'raises a TypeError exception' do
        expect { Convert.components([]) }.to raise_error(TypeError)
      end
    end

    context 'given a hash of components' do
      it 'converts the components to server-friendly format' do
        expect(
            Convert.components({'country' => %w(US AU), 'foo' => 1})
        ).to eql('country:AU|country:US|foo:1')
      end
    end
  end

  describe '.bounds' do
    context 'given an argument of wrong type' do
      it 'raises a TypeError exception' do
        expect { Convert.bounds([]) }.to raise_error(TypeError)
      end
    end

    context 'given a hash of bounds' do
      it 'converts lat/lng bounds to a comma- and pipe-separated string' do
        sydney_bounds = {
          :northeast => { :lat => -33.4245981, :lng => 151.3426361 },
          :southwest => { :lat => -34.1692489, :lng => 150.502229  }
        }
        expect(Convert.bounds(sydney_bounds)).to eql('-34.1692489,150.502229|-33.4245981,151.3426361')
      end
    end
  end

  describe '.encode_polyline' do
    context 'given an argument of wrong type' do
      it 'raises a TypeError exception' do
        expect { Convert.encode_polyline({}) }.to raise_error(TypeError)
      end
    end

    context 'given an array of points' do
      it 'encodes the array into a polyline string' do
        expect(Convert.encode_polyline([{:lat => 40.714728, :lng => -73.998672}])).to eql('abowFtzsbM')
      end
    end
  end

  describe '.decode_polyline' do
    context 'given an argument of wrong type' do
      it 'raises a TypeError exception' do
        expect { Convert.decode_polyline({}) }.to raise_error(TypeError)
      end
    end

    context 'given a polyline string' do
      it 'decodes the polyline string into an array of lat/lng hashes' do
        expect(Convert.decode_polyline('abowFtzsbM')).to eql([{:lat => 40.71473, :lng => -73.99867}])
      end
    end
  end

  describe '.get_mime_type' do
    context 'given the Content-Type header value' do
      it 'returns the MIME-Type value' do
        content_type = "application/json; charset=UTF-8"
        expect(Convert.get_mime_type(content_type)).to eql('application/json')
      end
    end
  end

  describe '.rectangular_dimensions' do
    context 'given an argument of wrong type' do
      it 'raises a TypeError exception' do
        expect { Convert.rectangular_dimensions([]) }.to raise_error(TypeError)
      end
    end

    context 'given a hash with horizontal and vertical values' do
      it 'returns a string value in the form lengthxwidth' do
        expect(Convert.rectangular_dimensions({:length => 640, :width => 300})).to eql('640x300')
      end
    end
  end

end
