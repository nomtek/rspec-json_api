# frozen_string_literal: true

module Rspec
  module JsonApi
    module Interfaces
      class ExampleInterface
        def self.schema
          {
            id: Types::UUID,
            name: String,
            number: Integer,
            color: -> { { inclusion: %w[black red white] }}
          }
        end
      end
    end
  end
end
