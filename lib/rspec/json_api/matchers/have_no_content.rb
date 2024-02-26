# frozen_string_literal: true

module RSpec
  module JsonApi
    module Matchers
      # The HaveNoContent class is designed to verify that a given string is empty.
      #
      # This matcher is primarily used within RSpec tests to assert that a given
      # string lacks content, effectively ensuring that expected content is absent,
      # which can be particularly useful in testing API responses or other outputs
      # where the absence of content signifies a specific state or outcome.
      class HaveNoContent
        # Determines whether the actual string is empty, signifying no content.
        #
        # @param actual [String] The string to be evaluated.
        # @return [Boolean] Returns true if the string is empty, indicating no content; false otherwise.
        def matches?(actual)
          actual == ""
        end

        # Provides a failure message for when the actual string contains content,
        # contrary to the expectation of being empty.
        #
        # @return [String] A descriptive message indicating the expectation was for
        #   the string to have no content, yet content was found.
        def failure_message
          "expected the string to be empty but it contained content"
        end

        # Provides a failure message for when the expectation is negated (i.e.,
        # expecting content) and the actual string is unexpectedly empty.
        #
        # @return [String] A descriptive message indicating that content was expected
        #   in the string, but it was found to be empty.
        def failure_message_when_negated
          "expected the string not to be empty, yet it was devoid of content"
        end
      end
    end
  end
end
