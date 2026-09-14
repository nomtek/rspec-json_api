# RSpec::JsonApi

`rspec-json_api` adds RSpec matchers for checking JSON values against compact Ruby schemas. Despite the name, it validates general JSON response shapes; it does not implement the [JSON:API specification](https://jsonapi.org/).

## Requirements

- Ruby 3.2 or newer
- RSpec 3
- Rails 6.1 or newer only when using the optional generators

The CI suite covers matcher behavior on Ruby 3.2, 3.3, 3.4, and 4.0. Generator integration is exercised at the supported Rails boundaries: Rails 6.1 on Ruby 3.2 and Rails 8.1 on Ruby 3.4.

## Installation

Add the gem to your test group:

```ruby
group :test do
  gem "rspec-json_api"
end
```

Then run:

```sh
bundle install
```

Load the matchers from `spec/spec_helper.rb` (or your equivalent RSpec setup file):

```ruby
require "rspec/json_api"
```

Rails projects can generate the definition directories:

```sh
rails generate rspec:json_api:install
```

Load custom types before interfaces in `rails_helper.rb`, because interfaces may reference types:

```ruby
Dir[File.join(__dir__, "rspec", "json_api", "types", "*.rb")].each { |file| require file }
Dir[File.join(__dir__, "rspec", "json_api", "interfaces", "*.rb")].each { |file| require file }
```

The matchers themselves do not depend on Rails, ActiveSupport, or `rspec-rails`.

## Matchers

### `match_json_schema`

Pass the matcher a JSON String and describe the parsed value with Ruby values, classes, regular expressions, arrays, hashes, or constraint Procs:

```ruby
schema = {
  id: RSpec::JsonApi::Types::UUID,
  name: String,
  age: -> { { type: Integer, min: 18 } },
  tags: [String]
}

expect(response.body).to match_json_schema(schema)
```

The actual value must be a JSON String. Invalid JSON and non-String inputs fail the match. Schema keys must be symbols because JSON object keys are symbolized while parsing.

Object schemas are strict at every nesting level: every expected key must be present and unexpected keys fail the match. `allow_blank` permits a blank value; it does not make a key optional.

Root schemas may describe objects, arrays, or scalar JSON values:

```ruby
expect('"ready"').to match_json_schema(String)
expect('"ready"').to match_json_schema(/\Aready\z/)
expect("42").to match_json_schema(42)
```

### `have_no_content`

`have_no_content` matches only an empty String:

```ruby
expect(response.body).to have_no_content
```

JSON objects, JSON arrays, and whitespace-only bodies are considered content.

## Schema Values

### Exact values

```ruby
schema = { status: "ready", count: 2 }
```

### Classes

Classes use `instance_of?`, so subclasses do not match:

```ruby
schema = { id: Integer, name: String }
```

### Regular expressions

A regular expression matches only a JSON String. Numbers, booleans, and `null` do not match after conversion:

```ruby
schema = { color: /\A#[0-9a-fA-F]{6}\z/ }
```

Use `\A` and `\z` for whole-string validation. Ruby's `^` and `$` are line anchors and may accept a matching line inside a multiline value.

### Arrays

Array schemas have three forms:

```ruby
[String]                         # any-length list of Strings
[{ id: Integer, name: String }] # any-length list of this object shape
[Integer, String]               # an exact two-element tuple
```

The one-element shorthand applies only to a Class or Hash. For example, `[Types::UUID]` means an exact one-element array because `Types::UUID` is a Regexp.

### Constraint Procs

A constraint Proc takes no arguments and returns an options Hash:

```ruby
schema = {
  age: -> { { type: Integer, min: 18, max: 120 } },
  role: -> { { inclusion: %w[admin member] } },
  code: -> { { regex: /\A[A-Z]{3}\z/ } },
  even: -> { { lambda: ->(value) { value.even? } } },
  nickname: -> { { type: String, allow_blank: true } }
}
```

Supported options are `allow_blank`, `type`, `value`, `min`, `max`, `inclusion`, `regex`, and `lambda`. All supplied constraints must pass. Unknown options, a non-Hash return value, or a Proc that declares an argument raises `ArgumentError` with usage guidance.

`allow_blank: true` accepts `null`, `false`, empty strings, whitespace-only strings, empty arrays, and empty objects. The key itself remains required.

## Built-in Types

The built-in types are anchored regular expressions:

```ruby
RSpec::JsonApi::Types::EMAIL
RSpec::JsonApi::Types::URI
RSpec::JsonApi::Types::UUID
```

`URI` accepts schemes supported by Ruby's standard URI parser, not only HTTP and HTTPS.

Generate a custom type with Rails:

```sh
rails generate rspec:json_api:type color_hex
```

Or define one directly:

```ruby
module RSpec
  module JsonApi
    module Types
      COLOR_HEX = /\A#(?:[0-9a-fA-F]{3}){1,2}\z/
    end
  end
end
```

## Interfaces

Interfaces are reusable strict object schemas:

```ruby
module RSpec
  module JsonApi
    module Interfaces
      PERSON = {
        id: Types::UUID,
        name: String,
        active: -> { { inclusion: [true, false] } }
      }.freeze
    end
  end
end
```

Generate one with:

```sh
rails generate rspec:json_api:interface person
```

Use an interface directly or as a homogeneous list schema:

```ruby
expect(response.body).to match_json_schema(RSpec::JsonApi::Interfaces::PERSON)
expect(response.body).to match_json_schema([RSpec::JsonApi::Interfaces::PERSON])
```

## Development

Use the Ruby version in `.ruby-version` and Bundler 4.0.4:

```sh
gem install bundler -v 4.0.4
bundle install
bundle exec rspec
bundle exec rubocop
bundle exec bundle-audit check --update
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for compatibility and contribution guidance. Please report vulnerabilities using [GitHub's private security advisory form](https://github.com/nomtek/rspec-json_api/security/advisories/new), as described in [SECURITY.md](SECURITY.md).

## License

The gem is available under the terms of the [MIT License](LICENSE.txt).

## Code of Conduct

Everyone participating in this project is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).
