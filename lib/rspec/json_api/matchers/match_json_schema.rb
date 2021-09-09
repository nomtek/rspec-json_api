# frozen_string_literal: true

RSpec::Matchers.define :match_json_schema do |expected|
  match do |actual|
    # Parse JSON object into hash
    actual = JSON.parse(actual, symbolize_names: true)

    # Compare keys schema
    return false unless actual.deep_keys == expected.deep_keys

    # Compare respond with gicen schema
    return false unless Rspec::JsonApi::CompareHash.compare(actual, expected)

    true
  end
end
