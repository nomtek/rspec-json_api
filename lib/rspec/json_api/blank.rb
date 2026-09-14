# frozen_string_literal: true

module RSpec
  module JsonApi
    module Blank
      module_function

      BLANK_STRING = /\A[[:space:]]*\z/

      def blank?(value)
        case value
        when nil, false
          true
        when String
          BLANK_STRING.match?(value)
        else
          value.respond_to?(:empty?) && value.empty?
        end
      end
    end
  end
end
