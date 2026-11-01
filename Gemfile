# frozen_string_literal: true

# Bundler version: 4.0.23 (see Gemfile.lock BUNDLED WITH section)
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Runtime dependencies come from the gemspec.
gemspec

gem "rake", "~> 13.4"
gem "rspec", "~> 3.13"
# Held on 0.22: simplecov 1.x requires Ruby >= 3.3, and every test leg loads it,
# including the Ruby 3.2 one that proves the gem's required_ruby_version.
gem "simplecov", "~> 0.22"

# Only the lint job needs these, and it runs a current Ruby. Keeping them out of
# the matcher test legs lets their dependency tree (parallel 2.x needs Ruby
# >= 3.3) stay current without breaking the Ruby 3.2 leg.
group :lint do
  gem "bundler-audit", "~> 0.9"
  gem "rubocop", "~> 1.92"
end

group :generators do
  gem "railties", ">= 6.1.4.1"
  gem "rspec-rails", ">= 5.0.2"
end
