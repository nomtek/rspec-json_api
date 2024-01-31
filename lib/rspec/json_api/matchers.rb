# frozen_string_literal: true

module RSpec
  module Matchers
    def match_json_schema(expected)
      RSpec::JsonApi::Matchers::MatchJsonSchema.new(expected)
    end

    def have_no_content
      RSpec::JsonApi::Matchers::HaveNoContent.new
    end
  end
end
