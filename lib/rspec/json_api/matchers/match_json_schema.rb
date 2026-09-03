# frozen_string_literal: true

module RSpec
  module JsonApi
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
          @diff = nil
          @actual = actual
          @type_error = !actual.is_a?(String)

          return false if @type_error

          @actual = JSON.parse(actual, symbolize_names: true)

          RSpec::JsonApi::SchemaMatch.match(@actual, expected)
        rescue JSON::ParserError
          @actual = actual
          false
        end

        # A non-String actual is a mistake in the spec rather than a fact about the
        # response, so the negated form has to fail rather than pass by default.
        # @param actual [String] The JSON string to test against the expected schema.
        # @return [Boolean] true if the actual JSON does not match the expected schema.
        def does_not_match?(actual)
          !matches?(actual) && !@type_error
        end

        # Provides a failure message for when the JSON data does not match the expected schema.
        # @return [String] A descriptive message detailing the mismatch between expected and actual JSON.
        def failure_message
          return type_error_message if @type_error

          <<~MSG
            expected: #{expected}
                 got: #{actual}

            Diff:
            #{diff}
          MSG
        end

        # Provides a failure message for when the JSON data matches the expected schema, but it was expected not to.
        # This is used in negative matchers.
        # @return [String] A descriptive message indicating the JSON was expected not to match the schema.
        def failure_message_when_negated
          return type_error_message if @type_error

          "expected the JSON data not to match the provided schema, but it did."
        end

        private

        # The diff is only needed to render a failure message, so it is built
        # lazily and memoized rather than on every matches? call.
        def diff
          @diff ||= Diffy::Diff.new(expected, actual, context: 5)
        end

        def type_error_message
          "expected a JSON String to match against the schema, got #{actual.class}"
        end
      end
    end
  end
end
