# frozen_string_literal: true

# Load 3th party libraries
require "rspec/matchers"
require "json"
require "active_support/core_ext/object/blank"

# Load the json_api parts
require "extentions/hash"
require "rspec/json_api/version"
require "rspec/json_api/compare_hash"

# Load matcher
require "rspec/json_api/matchers"
require "rspec/json_api/matchers/match_json_schema"

# Load defined types
require "rspec/json_api/types/email"
require "rspec/json_api/types/uri"
require "rspec/json_api/types/uuid"

# Load example interface
require "rspec/json_api/interfaces/example_interface"
