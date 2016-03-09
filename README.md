# Attributor::Flatpack
[![Build Status](https://travis-ci.org/careo/attributor-flatpack.svg?branch=master)](https://travis-ci.org/careo/attributor-flatpack)
[![Code Climate](https://codeclimate.com/github/careo/attributor-flatpack/badges/gpa.svg)](https://codeclimate.com/github/careo/attributor-flatpack)
[![Test Coverage](https://codeclimate.com/github/careo/attributor-flatpack/badges/coverage.svg)](https://codeclimate.com/github/careo/attributor-flatpack/coverage)

This library provides an Attributor type, Attributor::Flatpack::Config, for loading messy data from sources like the ENV hash. Based on the Go [flatpack](https://github.com/xeger/flatpack) library.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'attributor-flatpack'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install attributor-flatpack

## Usage

Define your config type, similarly to an `Attributor::Hash`:

```ruby
class SampleConfig < Attributor::Flatpack::Config
  keys do
    key :rack_env, String
    key :database do
      key :host, String
      key :username, String
      key :password, String
    end
    key :web do
      key :maxconn, Integer
      key :workers, Integer
    end
  end
end
```

Create an instance of it from a given input hash:
```ruby
config = SimpleConfig.load(ENV)
```

And then simply use the attributes defined to retrieve values:
```ruby
config.rack_env
# => development
config.database.host
# => localhost:9160
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/attributor-flatpack.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
