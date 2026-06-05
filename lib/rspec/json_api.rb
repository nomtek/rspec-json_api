# frozen_string_literal: true

# Load 3rd party libraries
require "json"
require "uri"
require "diffy"
require "active_support/core_ext/object/blank"

# Load the json_api parts
require "rspec/json_api/version"
require "rspec/json_api/traversal"
require "rspec/json_api/constraints"
require "rspec/json_api/schema_match"

# Load matchers
require "rspec/json_api/matchers"
require "rspec/json_api/matchers/match_json_schema"
require "rspec/json_api/matchers/have_no_content"

# Load defined types
require "rspec/json_api/types/email"
require "rspec/json_api/types/uri"
require "rspec/json_api/types/uuid"
