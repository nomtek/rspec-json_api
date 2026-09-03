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

  # Ship what a consumer loads and nothing else: the library, the generators
  # (templates included, so the dotfile markers that keep the empty interface
  # and type directories must be globbed too), plus the licence and reference
  # documents. Listing every tracked file, as `git ls-files` did, packaged the
  # repository's own tooling inside the released gem: the CI workflow, the
  # RuboCop config, the Gemfile and lockfile, the Rakefile, bin/ and gemfiles/.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob("lib/**/*", File::FNM_DOTMATCH).select { |f| File.file?(f) }.sort +
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
