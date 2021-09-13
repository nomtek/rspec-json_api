# frozen_string_literal: true

module Rspec
  module JsonApi
    module CompareHash
      extend self

      SUPPORTED_OPTIONS = %i[optional type value min max inclusion regex lambda].freeze

      def compare(actual, expected)
        return false if actual.blank? && expected.present?

        key_paths = actual.deep_key_paths

        key_paths.all? do |key_path|
          actual_value = actual.dig(*key_path)
          expected_value = expected.dig(*key_path)

          compare_hash_values(actual_value, expected_value)
        end
      end

      private

      def compare_hash_values(actual_value, expected_value)
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
          compare_value(actual_value, expected_value)
        end
      end

      def compare_class(actual_value, expected_value)
        actual_value.instance_of?(expected_value)
      end

      def compare_regexp(actual_value, expected_value)
        expected_value =~ actual_value
      end

      def compare_proc(actual_value, expected_value)
        payload = expected_value.call
        payload.sanitize!(SUPPORTED_OPTIONS)

        payload.all? do |condition_key, condition_value|
          case condition_key
          when :type
            compare_class(actual_value, condition_value)
          when :value
            compare_value(actual_value, condition_value)
          when :inclusion
            condition_value.include?(actual_value)
          when :min
            return false unless condition_value.is_a?(Numeric)

            actual_value >= condition_value
          when :max
            return false unless condition_value.is_a?(Numeric)

            actual_value <= condition_value
          when :regex
            compare_regexp(actual_value, condition_value)
          when :lambda
            condition_value.call(actual_value)
          end
        end
      end

      def compare_array(actual_value, expected_value)
        if expected_value.size == 1 && expected_value[0].instance_of?(Class)
          type = expected_value[0]

          actual_value.all? { |elem| compare_class(elem, type) }
        elsif expected_value.size == 1 && expected_value[0].is_a?(Hash)
          interface = expected_value[0]

          actual_value.all? do |elem|
            compare(elem, interface)
          end
        else
          actual_value.each_with_index.all? do |elem, index|
            elem.is_a?(Hash) ? compare(elem, expected_value[index]) : compare_value(elem, expected_value[index])
          end
        end
      end

      def compare_value(actual_value, expected_value)
        actual_value == expected_value
      end
    end
  end
end
