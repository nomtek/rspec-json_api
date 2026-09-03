# frozen_string_literal: true

module RSpec
  module JsonApi
    module Types
      # URI::DEFAULT_PARSER.make_regexp is unanchored, and comparison uses
      # Regexp#match?, so on its own it accepts any string that merely contains
      # a URI ("see https://example.com for details"). \A...\z holds the whole
      # value to the pattern, the same way EMAIL and UUID already are anchored.
      URI = /\A#{::URI::DEFAULT_PARSER.make_regexp}\z/
    end
  end
end
