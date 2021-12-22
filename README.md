# RSpec::JsonApi

[RSpec:JsonAPI](https://github.com/nomtek/rspec-json_api) 
is an extension for [RSpec](https://github.com/rspec) 
to easily allow testing JSON API responses.

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

Require gem assets in your `spec_helper.rb`
```ruby
Dir[File.join(__dir__, 'rspec', 'json_api', '**', '*.rb')].each { |file| require file }
```

## Generators

Using build-in generators it's possible to create custom interface and type.

Generate new template:

    rails generate rspec:json_api:interface interface-name

Generate new type:

    rails generate rspec:json_api:type type-name


## Example usage

```ruby
# spec/controllers/users_controller_spec.rb

RSpec.describe UsersController, type: :controller do
  describe '#index' do
    let(:expected_schema) do
      Array[{
        id: RSpec::JsonApi::Types::UUID,
        name: String,
        age: Integer,
        favouriteColorHex: /^\#([a-fA-F]|[0-9]){3,6}$/,
        number: -> { { type: Integer, min: 10, max: 20, lambda: ->(actual) { actual.even? } } }
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
The gem introduces interfaces to reuse them during test matches.

```ruby
# spec/rspec/json_api/interfaces/example_interface.rb

module RSpec
  module JsonApi
    module Interfaces
      EXAMPLE_INTERFACE = {
        id: Types::UUID,
        name: String,
        number: Integer,
        color: -> { { inclusion: %w[black red white], allow_blank: true } }
      }.freeze
    end
  end
end
```
_Note: You can either generate file on your own or use generator._
## Types

The gem allow users either to user build-in types or define owns. 
### Build-in types
- #### EMAIL
```ruby
RSpec::JsonApi::Types::EMAIL
```
- #### URI
```ruby
RSpec::JsonApi::Types::URI
```
- #### UUID
```ruby
RSpec::JsonApi::Types::UUID
```


Custom type example:
```ruby
# spec/rspec/json_api/types/color_hex.rb

module RSpec
  module JsonApi
    module Types
      COLOR_HEX = /^#(?:[0-9a-fA-F]{3}){1,2}$/
    end
  end
end

RSpec::JsonApi::Types::COLOR_HEX
```

_Note: You can either generate file on your own or use generator._
## Matching methods
The gem offers variety of possible matching methods.

### Presumptions
- `match_json_schema` always require full keys match.

  Failure Example:
    ```ruby
    let(:expected) do
      {
        id: RSpec::JsonApi::Types::UUID,
        name: String,
        age: Integer
      }
    end
  
    let(:actual) do
      {
        id: "0a2f911f-3767-4cc7-9c19-049f4350e38c",
        name: "Mikel",
      }
    end
    ```
  
  Success Example:
  ```ruby
  let(:expected) do
    {
      id: RSpec::JsonApi::Types::UUID,
      name: String,
      age: Integer
    }
  end

  let(:actual) do
    {
      id: "0a2f911f-3767-4cc7-9c19-049f4350e38c",
      name: "John",
      age: 24
    }
  end
  ```

### Value match
```ruby
let(:expected_schema) do
  {
    id: "e0067346-4d24-4aa6-b303-f927a410a001",
    name: "John",
    age: 24,
    favouriteColorHex: "#FF5733"
  }
end
```

### Class match
```ruby
let(:expected_schema) do
  {
    id: Integer,
    name: String,
    age: Integer,
    notes: Array[String]
  }
end
```

### Type match
```ruby
let(:expected_schema) do
  {
    id: RSpec::JsonApi::Types::UUID,
    email: RSpec::JsonApi::Types::EMAIL,
  }
end
```

### Regexp match
```ruby
let(:expected_schema) do
  {
    color: /^\#([a-fA-F]|[0-9]){3,6}$/
  }
end
```

### Interface match
```ruby
let(:expected_schema) do
    Array[RSpec::JsonApi::Interfaces::PERSON]
end
```

### Proc match
Proc match allows to customize schema accoring needs using lambda shorthand notation `->`

Supported options:
- #### type
```ruby
let(:expected_schema) do
  {
    name: -> { { type: String } }
  }
end
```
- #### value
```ruby
let(:expected_schema) do
  {
    name: -> { { value: "John" } }
  }
end
```
- #### min
```ruby
let(:expected_schema) do
  {
    age: -> { { min: 15 } }
  }
end
```
- #### max
```ruby
let(:expected_schema) do
  {
    age: -> { { max: 25 } }
  }
end
```
- #### inclusion
```ruby
let(:expected_schema) do
  {
    letter: -> { { inclusion: %w[A B C] } }
  }
end
```
- #### regex
```ruby
let(:expected_schema) do
  {
    hex: -> { { regex: /^\#([a-fA-F]|[0-9]){3,6}$/ } }
  }
end
```
- #### lambda
```ruby
let(:expected) do
  {
    number: -> { { lambda: ->(actual) { actual.even? } } }
  }
end
```
- #### allow_blank

```ruby
let(:expected_schema) do
  {
    name: -> { { type: String, allow_blank: true } }
  }
end
```
_Note: Default value is `false`_

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nomtek/rspec-json_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/nomtek/rspec-json_api/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RSpec::JsonApi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nomtek/rspec-json_api/blob/master/CODE_OF_CONDUCT.md).
