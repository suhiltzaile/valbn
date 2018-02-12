# Valbn

Valbn is just a simple interface to check business numbers (currently supports EU countries, Australia and New Zealand) by using [valvat](https://github.com/yolk/valvat), [valabn](https://github.com/quaderno/valabn) and [valnzbn](https://github.com/quaderno/valnzbn). So instead, doing this in your app:

```ruby
  require 'valvat'
  require 'valabn'
  require 'valnzbn'

  if country.in? EUROPEAN_COUNTRIES
    Valvat.new(number).exists?
  elsif country == 'AU'
    Valabn.new(number).exists?
  elsif country == 'NZ'
    Valnzbn.new(number).exists?
  end
```

you can do this:

```ruby
  Valbn.new(number, country).exists?
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'valbn'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install valbn

Please keep in mind that you'll also need to install the gems for each specific service you want to use(`valvat`, `valabn` or `valnzbn`).

## Usage

First you need to initialize the gem to check to which services you want to validate.

```ruby
require 'valbn'

Valbn.configure do |config|
  config.vatmoss = true # Via valvat
  config.abn = true # Via valabn
  config.nzbn = true # Via valnzbn

  Valabn::Lookup.configure do |config|
    config.guid = ABN_GUID
  end

  Valnzbn::Lookup.configure do |config|
    config.access_token = NZBN_ACCESS_TOKEN
  end
end
```

After that you can use:

```ruby
number = '9429033558257'
country = 'NZ'

business_number = Valbn.new(number, country)

business_number.exists? # => True, false or nil
business_number.exists?(detail: true) # => Hash or nil
business_number.exists?(formatted: true) # => Hash or nil
```

The options `detail` and `formatted` returns a `Hash` with extra information about the requested business number. When `detail` is set the format will be the API-specific format but if you select `formatted`, the resulting hash will be normalized as:

```ruby
{
  original_format: {…}, # The original response as returned with "detail: true"
  name: 'Company name',
  street_line_1: 'Street line 1',
  street_line_2: 'Street line 2',
  region: 'Region',
  city: 'City',
  postal_code: 'postal-code'
}
```

Please note that not all the fields can be filled as they depends on the values returned by each API.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/valbn. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

