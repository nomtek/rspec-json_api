# frozen_string_literal: true

# Bundler version: 4.0.23 (see Gemfile.lock BUNDLED WITH section)
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Runtime dependencies come from the gemspec.
gemspec

gem "rake", "~> 13.4"
gem "rspec", "~> 3.13"
gem "simplecov", "~> 1.3"

# Only the lint job needs these, and it runs a current Ruby. Keeping them out of
# the matcher test legs lets their dependency tree require a newer Ruby than
# the gem's floor without breaking the oldest leg, and those legs install less.
group :lint do
  gem "bundler-audit", "~> 0.9"
  gem "rubocop", "~> 1.92"
end

group :generators do
  gem "railties", ">= 6.1.4.1"
  gem "rspec-rails", ">= 5.0.2"
end
