# frozen_string_literal: true

module RSpec
  module JsonApi
    module Matchers
      class HaveNoContent
        def matches?(actual)
          actual == ""
        end

        def failure_message
          self
        end

        def failure_message_when_negated
          self
        end
      end
    end
  end
end
