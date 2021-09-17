# frozen_string_literal: true

module RSpec
  module JsonApi
    module Interfaces
      EXAMPLE_INTERFACE = {
        id: Types::UUID,
        name: String,
        number: Integer,
        color: -> { { inclusion: %w[black red white], allow_blank: true } }
      }.freeze
    end
  end
end
