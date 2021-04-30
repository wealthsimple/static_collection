# 
[![GitHub Actions Badge](https://github.com/wealthsimple//actions/workflows/main.yml/badge.svg)](https://github.com/wealthsimple//actions)

Rubygem for running basic queries against static data.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'static_collection'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install static_collection

## Usage

To create a StaticCollection model, inherit from `StaticCollection::Base`

```ruby
class AccountType < StaticCollection::Base
end
```

Then set the source for the static collection data. To read from YAML,

```ruby
class AccountType < StaticCollection::Base
  set_source YAML.load_file('./data/account_types_test.yml')
end
```

To set a default value for an attribute, pass a defaults hash into `set_source`

```ruby
class AccountType < StaticCollection::Base
  set_source YAML.load_file('./data/account_types_test.yml'), defaults: { recommended_by_default: false }
end
```

StaticCollection supports the following query methods: `:count`, `:all`, `:find_by`, and `:where`.

```ruby
> AccountType.find_by(type: 'joint').ownership_type
=> "multi-owner"
```

To see the full `AccountType` example, take a look at our [blog post](http://code.wealthsimple.com/introducing-staticcollection-an-activerecord-interface-for-static-data/).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
