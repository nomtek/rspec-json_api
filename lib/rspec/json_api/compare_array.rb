# frozen_string_literal: true

module RSpec
  module JsonApi
    module CompareArray
      extend self

      def compare(actual, expected)
        if interface?(expected)
          actual.all? do |actual_elem|
            return false unless actual_elem.deep_keys == expected[0].deep_keys

            CompareHash.compare(actual_elem, expected[0])
          end
        else
          actual.each_with_index.all? do |actual_elem, index|
            compare_primitive_type_element(actual, expected, actual_elem, index)
          end
        end
      end

      private

      def interface?(expected_value)
        expected_value.size == 1 && expected_value[0].is_a?(Hash)
      end

      def compare_primitive_type_element(actual, expected, actual_elem, index)
        if actual[index].respond_to?(:deep_keys) && expected[index].respond_to?(:deep_keys)
          return false unless actual[index].deep_keys == expected[index].deep_keys

          CompareHash.compare(actual_elem, expected[index])
        else
          CompareHash.compare_values(actual[index], expected[index])
        end
      end
    end
  end
end
