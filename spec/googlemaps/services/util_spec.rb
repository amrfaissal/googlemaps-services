require "googlemaps/services/util"

include GoogleMaps::Services

describe Util do
  now = Time.parse("1969-07-20 20:17:40")
  before {
    allow(Time).to receive(:now) { now }
  }

  describe ".current_time" do
    it "returns the current time" do
      expect(Util.current_time).to eql(now)
    end
  end

  describe ".current_unix_time" do
    it "returns current time in unix format" do
      expect(Util.current_unix_time).to eql(-14186540)
    end
  end

  describe ".sign_hmac" do
    secret = "AIzaBuyMirfbsiR91cw_JCDJ5Cwoocho4tZi7g"
    payload = "This is a secret message"
    it "returns base64-encoded HMAC-SHA1 signature of a given payload" do
      expect(Util.sign_hmac(secret, payload)).to eql("5ycjCDFR5wfb01f23GhkdhkhxEA=")
    end
  end

  describe ".urlencode_params" do
    params = {
      "origins" => "Sydney",
      "destinations"=>"New York",
      "key"=>"AIzaBuyMirfbsiR91cw_JAD89Cwoocho4tZi7g"
    }
    expected = "origins=Sydney&destinations=New+York&key=AIzaBuyMirfbsiR91cw_JAD89Cwoocho4tZi7g"
    it "generates URL-encoded parameters" do
      expect(Util.urlencode_params(params)).to eql(expected)
    end
  end

end

describe Convert do

  describe ".unix_time" do
    context "given value of type Integer" do
      expected = "1472318142"
      it "returns unix time since epoch" do
        expect(Convert.unix_time(1472318142)).to eql(expected)
      end
    end

    context "given value of type Time" do
      time = Time.parse("2016-08-27 19:15:42 +0200")
      expected = "1472318142"
      it "returns unix time since epoch" do
        expect(Convert.unix_time(time)).to eql(expected)
      end
    end

    context "given value of type Date" do
      date = Date.new(2016, 8, 27)
      expected = "1472248800"
      it "returns unix time since epoch" do
        expect(Convert.unix_time(date)).to eql(expected)
      end
    end

    context "given value of wrong type" do
      it "raises a TypeError exception" do
        expect{
          Convert.unix_time({})
        }.to raise_error(TypeError)
      end
    end
  end

  describe ".to_latlng" do
    context "given a location of type String" do
      it "returns the location itself" do
        expect(Convert.to_latlng("Sydney")).to eql("Sydney")
      end
    end

    context "given a location of type Hash" do
      it "returns the location in comma-separated string" do
        expect(
          Convert.to_latlng({
            :lat => -33.865143,
            :lng => 151.209900
            })
        ).to eql("-33.865143,151.2099")
      end
    end

    context "given a location of wrong type" do
      it "raises a TypeError exception" do
        expect {
          Convert.to_latlng([-33.865143, 151.2099])
        }.to raise_error(TypeError)
      end
    end
  end

  describe ".format_float" do
    it "formats a float value to as short as possible" do
      expect(Convert.format_float(151.209900)).to eql("151.2099")
    end
  end

  describe ".piped_location" do
    context "given an argument of wrong type" do
      it "raises a TypeError exception" do
        expect {
          Convert.piped_location({})
        }.to raise_error(TypeError)
      end
    end

    context "given an array of locations that are not a String or Hash" do
      it "raises a TypeError exception" do
        expect {
          Convert.piped_location(["Sydney", [-33.865143, 151.2099]])
        }.to raise_error(TypeError)
      end
    end

    context "given an array of locations of type String or Array" do
      it "returns a pipe separated string" do
        expect(
          Convert.piped_location(
            ["Sydney",{ :lat => -33.865143, :lng => 151.209900}])
        ).to eql("Sydney|-33.865143,151.2099")
      end
    end
  end

  describe ".join_list" do
    context "given an argument of wrong type" do
      it "raises a TypeError exception" do
        expect {
          Convert.join_list("|", {})
        }.to raise_error(TypeError)
      end
    end

    context "given an argument of type Array" do
      it "joins the array with a separator" do
        expect(Convert.join_list(";", [1,2,3])).to eql("1;2;3")
      end
    end
  end

end
