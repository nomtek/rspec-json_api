# frozen_string_literal: true

require_relative "lib/rspec/json_api/version"

Gem::Specification.new do |spec|
  spec.name          = "rspec-json_api"
  spec.version       = Rspec::JsonApi::VERSION
  spec.authors       = ["Michal Gajowiak"]
  spec.email         = ["m.gajowiak@nomtek.com"]

  spec.summary       = "Rspec extension to test JSON API response."
  spec.homepage      = "https://github.com/nomtek/rspec-json_api"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nomtek/rspec-json_api"
  spec.metadata["changelog_uri"] = "https://github.com/nomtek/rspec-json_api/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "rspec-rails", "~> 3.4"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
