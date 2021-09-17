# frozen_string_literal: true

module RSpec
  module JsonApi
    module Matchers
      class MatchJsonSchema
        attr_reader :expected

        def initialize(expected)
          @expected = expected
        end

        def matches?(actual)
          actual = JSON.parse(actual, symbolize_names: true)

          # Compare actual and expected hashes schema
          return false unless actual.deep_keys == expected.deep_keys

          # Compare actual and expected hashes
          return false unless RSpec::JsonApi::CompareHash.compare(actual, expected)

          true
        end
      end
    end
  end
end
