# frozen_string_literal: true

module Rspec
  module JsonApi
    module Interfaces
      EXAMPLE_INTERFACE = {
        id: Types::UUID,
        name: String,
        number: Integer,
        color: -> { { inclusion: %w[black red white] } }
      }.freeze
    end
  end
end
