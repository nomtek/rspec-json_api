# frozen_string_literal: true

module RSpec
  module JsonApi
    module Matchers
      class MatchJsonSchema
        attr_reader :expected, :actual

        def initialize(expected)
          @expected = expected
        end

        def matches?(actual)
          # Parse JSON to ruby object
          @actual = JSON.parse(actual, symbolize_names: true)
          @diff = Diffy::Diff.new(expected, @actual, context: 5)

          # Compare types
          return false unless @actual.instance_of?(expected.class)

          if expected.instance_of?(Array)
            RSpec::JsonApi::CompareArray.compare(@actual, expected)
          else
            # Compare actual and expected schema
            return false unless @actual.deep_keys.deep_sort == expected.deep_keys.deep_sort

            RSpec::JsonApi::CompareHash.compare(@actual, expected)
          end
        end

        def failure_message
          <<~MSG
            expected: #{expected}
                 got: #{actual}

            Diff:
            #{@diff}
          MSG
        end

        def failure_message_when_negated
          self
        end
      end
    end
  end
end
