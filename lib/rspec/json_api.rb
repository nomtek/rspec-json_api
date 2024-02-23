# frozen_string_literal: true

# Load 3th party libraries
require "json"
require "active_support/core_ext/object/blank"

# Load the json_api parts
require "rspec/json_api/version"
require "rspec/json_api/compare_hash"
require "rspec/json_api/compare_array"

# Load extentions
require "extentions/hash"
require "extentions/array"

# Load matchers
require "rspec/json_api/matchers"
require "rspec/json_api/matchers/match_json_schema"
require "rspec/json_api/matchers/have_no_content"

# Load defined types
require "rspec/json_api/types/email"
require "rspec/json_api/types/uri"
require "rspec/json_api/types/uuid"
