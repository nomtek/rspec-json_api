# frozen_string_literal: true

module RSpec
  module JsonApi
    module CompareHash
      module_function

      def compare(actual, expected)
        return false if actual.blank? && expected.present?

        keys = expected.deep_key_paths | actual.deep_key_paths

        compare_key_paths_and_values(keys, actual, expected)
      end

      def compare_key_paths_and_values(keys, actual, expected)
        keys.all? do |key_path|
          actual_value = dig_path(actual, key_path)
          expected_value = dig_path(expected, key_path)

          compare_values(actual_value, expected_value)
        end
      end

      # Digs a key path without raising when an intermediate value is not a Hash.
      # Plain Hash#dig raises TypeError if it walks into a scalar (e.g. a schema
      # expects a nested object but the actual value is a String), so a mismatch
      # would crash instead of failing the match.
      def dig_path(data, key_path)
        key_path.reduce(data) do |value, key|
          break nil unless value.is_a?(Hash)

          value[key]
        end
      end

      def compare_values(actual_value, expected_value)
        case expected_value
        when Class
          compare_class(actual_value, expected_value)
        when Regexp
          compare_regexp(actual_value, expected_value)
        when Proc
          compare_proc(actual_value, expected_value)
        when Array
          compare_array(actual_value, expected_value)
        else
          compare_simple_value(actual_value, expected_value)
        end
      end

      def compare_class(actual_value, expected_value)
        actual_value.instance_of?(expected_value)
      end

      def compare_regexp(actual_value, expected_value)
        expected_value.match?(actual_value.to_s)
      end

      def compare_proc(actual_value, expected_value)
        Constraints.match(actual_value, expected_value.call)
      end

      def compare_array(actual_value, expected_value)
        if simple_type?(expected_value)
          type = expected_value[0]

          actual_value.all? { |elem| compare_class(elem, type) }
        elsif interface?(expected_value)
          interface = expected_value[0]

          actual_value.all? { |elem| compare(elem, interface) }
        else
          return false if actual_value&.size != expected_value&.size

          expected_value.each_with_index.all? do |elem, index|
            elem.is_a?(Hash) ? compare(actual_value[index], elem) : compare_simple_value(actual_value[index], elem)
          end
        end
      end

      def compare_simple_value(actual_value, expected_value)
        actual_value == expected_value
      end

      def simple_type?(expected_value)
        expected_value.size == 1 && expected_value[0].instance_of?(Class)
      end

      def interface?(expected_value)
        expected_value.size == 1 && expected_value[0].is_a?(Hash)
      end
    end
  end
end
