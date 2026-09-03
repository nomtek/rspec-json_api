# frozen_string_literal: true

require_relative "lib/rspec/json_api/version"

Gem::Specification.new do |spec|
  spec.name          = "rspec-json_api"
  spec.version       = RSpec::JsonApi::VERSION
  spec.authors       = ["Michal Gajowiak"]
  spec.email         = ["m.gajowiak@nomtek.com"]

  spec.summary       = "RSpec extension to test JSON API response."
  spec.homepage      = "https://github.com/nomtek/rspec-json_api"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.2.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nomtek/rspec-json_api"
  spec.metadata["changelog_uri"] = "https://github.com/nomtek/rspec-json_api/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Ship what a consumer loads and nothing else: the library and generators
  # (dotfile markers included, so the empty template directories survive), plus
  # the licence and reference documents. Scoping `git ls-files` to lib/ keeps the
  # repository's own tooling out without letting untracked artefacts in.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z lib`.split("\x0").select { |f| File.file?(f) }.sort +
      %w[CHANGELOG.md LICENSE.txt README.md]
  end
  spec.require_paths = ["lib"]

  # Runtime dependencies. The gem only needs ActiveSupport's blank?/present?
  # core extensions and Rails::Generators (which lives in railties); depending
  # on the full "rails" meta-gem would force ActiveRecord, ActionCable,
  # ActionMailer, ActionMailbox, ActiveStorage, ActionText, etc. on every
  # consumer of a JSON-matcher gem. The >= 6.1.4.1 floor is unchanged.
  spec.add_dependency "activesupport", ">= 6.1.4.1"
  spec.add_dependency "diffy", ">= 3.4.2"
  spec.add_dependency "railties", ">= 6.1.4.1"
  spec.add_dependency "rspec-rails", ">= 5.0.2"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
