# RSpec::JsonApi

RSpec:JsonAPI is an extension for RSpec to easily allow to test JSON API responses.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-json_api'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rspec-json_api

Generate directory tree:

    rails generate rspec:json_api:install

## Generators

Using build-in generators it's possible to create custom interface and type.

Generate new template:

    rails generate rspec:json_api:interface interface-name

Generate new type:

    rails generate rspec:json_api:types type-name


## Example usage

```ruby
RSpec.describe UsersController, type: :controller do
  describe '#index' do
    let(:expected_schema) do
      Array[{
        id: RSpec::JsonApi::Types::UUID,
        name: String,
        age: Integer,
        favouriteColorHex: /^\#([a-fA-F]|[0-9]){3,6}$/
      }]
    end

    it 'matches API response' do
      get :index

      expect(response.body).to match_json_schema(expected_schema)
    end
  end
end
```

## Built-in matchers
- ### match_json_schema
```
  expect(response.body).to match_json_schema(expected_schema)
```

## Interfaces

## Types

## Build-in types
- #### EMAIL
- #### URI
- #### UUID


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nomtek/rspec-json_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rspec-json_api/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RSpec::JsonApi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rspec-json_api/blob/master/CODE_OF_CONDUCT.md).
