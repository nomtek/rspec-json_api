# frozen_string_literal: true

module Rspec
  module JsonApi
    module CompareHash
      extend self

      SUPPORTED_OPTIONS = %i[type value min max inclusion regex lambda].freeze

      def compare(actual, expected)
        key_paths = actual.deep_key_paths

        key_paths.all? do |key_path|
          actual_value = nil
          expected_value = nil

          key_path.each_with_object([]) do |elem, memo|
            memo << [memo, elem].flatten
            expected_value = expected[*memo[0]]
            actual_value = actual[*memo[0]]
            break unless expected_value.is_a?(Hash)
          end

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
        when Hash
          # It occours only for interfaces
          compare(actual_value, expected_value)
        else
          compare_value(actual_value, expected_value)
        end
      end

      def compare_class(actual_value, expected_value)
        if expected_value.respond_to?(:schema)
          schema = expected_value.schema

          compare(actual_value, schema)
        else
          actual_value.instance_of?(expected_value)
        end
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
        else
          compare_value(actual_value, expected_value)
        end
      end

      def compare_value(actual_value, expected_value)
        actual_value == expected_value
      end
    end
  end
end
