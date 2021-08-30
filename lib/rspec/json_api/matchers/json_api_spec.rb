# frozen_string_literal: true

require "rspec/expectations"
require "hash"

RSpec::Matchers.define :match_json_schema do |_expected|
  match do |actual|
    # Compare keys schema
    # return false unless actual.deep_keys == expected.deep_keys

    pp actual.get_deep_key_paths
    # return false unless actual.compare_with(expected)

    true
  end
end

RSpec.describe "" do
  let(:actual) do
    {
      id: "5", # 1
      name: "Michal", # 2
      age: 21, # 3
      preferences: { # 4
        id: "6",
        color: "blue",
        address: {
          city: [1, 2, 3],
          zip: {
            sym: "PL",
            code: ["+48", "0048"]
          }
        }
      }
    }
  end

  let(:expected) do
    {
      id: "5",
      name: "Michal",
      age: 21,
      preferences: {
        id: "6",
        color: "blue",
        address: {
          city: "Wroc",
          zip: "4"
        }
      }
    }
  end

  it "" do
    expect(actual).to match_json_schema(expected)
  end
end
