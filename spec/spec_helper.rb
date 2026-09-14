# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  add_filter "/spec/"
  minimum_coverage 90
end

require "rspec/json_api"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  config.order = :random
  config.warnings = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
