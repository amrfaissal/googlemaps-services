# Ruby Client for Google Maps Services

[![Build Status](https://travis-ci.org/amrfaissal/googlemaps-services.svg?branch=master)](https://travis-ci.org/amrfaissal/googlemaps-services)
[![Coverage Status](https://coveralls.io/repos/github/amrfaissal/googlemaps-services/badge.svg?branch=master)](https://coveralls.io/github/amrfaissal/googlemaps-services?branch=master)
![](https://ruby-gem-downloads-badge.herokuapp.com/googlemaps-services?type=total)
[![Gem Version](https://badge.fury.io/rb/googlemaps-services.svg)](https://badge.fury.io/rb/googlemaps-services)

## Description

This library brings the Google Maps API Web Services to your Ruby/RoR application.

The Ruby Client for Google Maps Services is a Ruby Client library for the following Google Maps APIs:

 - [Directions API]
 - [Distance Matrix API]
 - [Elevation API]
 - [Geocoding API]
 - [Time Zone API]
 - [Roads API]
 - [Places API]
 - [Static Maps API]
 - [Street View Image API]
 - [Geolocation API]

It supports both JSON and XML response formats.

## Requirements

 - Ruby 2.1 or later.
 - A Google Maps API key.
 - Client ID and Client Secret (for Google Maps APIs Premium Plan customers).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'googlemaps-services'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install googlemaps-services
```

## Documentation

View the [reference documentation](http://www.rubydoc.info/gems/googlemaps-services).

## Usage

This example uses the [Directions API] with an API key:

```ruby
  require 'googlemaps/services/client'
  require 'googlemaps/services/directions'

  include GoogleMaps::Services

  client = GoogleClient.new(key: 'Add API key here', response_format: :json)
  directions = Directions.new(client)

  # Get directions via public transit in JSON format.
  # To return the result in XML format, change the Client response_format parameter to :xml.
  result = directions.query(origin: '75 9th Ave, New York, NY',
                            destination: 'MetLife Stadium Dr East Rutherford, NJ 07073',
                            mode: 'transit',
                            departure_time: Time.now)
  # Print the result
  puts result
```

For more usage examples, check out the [reference documentation](http://www.rubydoc.info/gems/googlemaps-services).

## Contributing

Bug reports, Pull requests and Stars are always welcome. For bugs and feature requests, [please create an issue](https://github.com/amrfaissal/googlemaps-services/issues/new).

### Donate

* [![Donate](https://img.shields.io/badge/Donate-PayPal-blue.svg)](https://www.paypal.me/amrfaissal)
* Bitcoin: 1EdwqtXhojU4LGhTwBLT1JpTb1d71oA89o

![](https://cloud.githubusercontent.com/assets/1248967/25093965/2ea18cde-2395-11e7-8368-3f761b0bd8b7.png)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[Directions API]: https://developers.google.com/maps/documentation/directions/
[Distance Matrix API]: https://developers.google.com/maps/documentation/distancematrix/
[Elevation API]: https://developers.google.com/maps/documentation/elevation/
[Geocoding API]: https://developers.google.com/maps/documentation/geocoding/
[Time Zone API]: https://developers.google.com/maps/documentation/timezone/
[Roads API]: https://developers.google.com/maps/documentation/roads/
[Places API]: https://developers.google.com/places/
[Static Maps API]: https://developers.google.com/maps/documentation/static-maps/
[Street View Image API]: https://developers.google.com/maps/documentation/streetview/
[Geolocation API]: https://developers.google.com/maps/documentation/geolocation
