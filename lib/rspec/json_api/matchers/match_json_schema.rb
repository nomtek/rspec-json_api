# frozen_string_literal: true

# RSpec module serving as a namespace.
module RSpec
  # JsonApi module for JSON API related matchers and utilities.
  module JsonApi
    # Matchers module containing various matchers for testing JSON APIs.
    module Matchers
      # MatchJsonSchema class is designed to match a given JSON against a predefined JSON schema.
      #
      # This matcher is useful for validating JSON structures in API responses or other JSON data
      # against a schema defined either as a Hash, an Array, or another JSON structure.
      class MatchJsonSchema
        # @return [Object] the expected JSON schema to match against
        attr_reader :expected
        # @return [Object] the actual JSON data being tested
        attr_reader :actual

        # Initializes the matcher with the expected JSON schema.
        # @param expected [Object] The expected JSON schema as a Hash, Array, or other JSON-compatible structure.
        def initialize(expected)
          @expected = expected
        end

        # Matches the actual JSON data against the expected schema.
        # @param actual [String] The JSON string to test against the expected schema.
        # @return [Boolean] true if the actual JSON matches the expected schema, false otherwise.
        def matches?(actual)
          @actual = JSON.parse(actual, symbolize_names: true)
          @diff = Diffy::Diff.new(expected, @actual, context: 5)

          return false unless @actual.instance_of?(expected.class)

          if expected.instance_of?(Array)
            RSpec::JsonApi::CompareArray.compare(@actual, expected)
          else
            return false unless @actual.deep_keys.deep_sort == expected.deep_keys.deep_sort

            RSpec::JsonApi::CompareHash.compare(@actual, expected)
          end
        end

        # Provides a failure message for when the JSON data does not match the expected schema.
        # @return [String] A descriptive message detailing the mismatch between expected and actual JSON.
        def failure_message
          <<~MSG
            expected: #{expected}
                 got: #{actual}

            Diff:
            #{@diff}
          MSG
        end

        # Provides a failure message for when the JSON data matches the expected schema, but it was expected not to.
        # This is used in negative matchers.
        # @return [self] Returns itself, but typically this method should be implemented to return a descriptive message
        def failure_message_when_negated
          "expected the JSON data not to match the provided schema, but it did."
        end
      end
    end
  end
end
