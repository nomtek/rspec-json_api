# Contributing

Bug reports and pull requests are welcome.

## Setup

Use the Ruby version declared in `.ruby-version` and Bundler 4.0.4:

```sh
gem install bundler -v 4.0.4
bundle install
```

Run the local checks before opening a pull request:

```sh
bundle exec rspec
bundle exec rubocop
bundle exec bundle-audit check --update
```

Matcher changes should include focused examples under `spec/rspec/json_api`. Generator changes should include examples under `spec/generators` and be checked against both appraisal gemfiles.

Keep pull requests focused and explain user-visible behavior changes in `CHANGELOG.md`. By participating, you agree to follow the [code of conduct](CODE_OF_CONDUCT.md).
