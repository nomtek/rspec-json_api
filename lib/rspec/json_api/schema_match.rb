# frozen_string_literal: true

module RSpec
  module JsonApi
    # SchemaMatch compares parsed JSON (a Hash, an Array, or a scalar) against an
    # expected schema. It is the single entry point behind the match_json_schema
    # matcher: callers hand it the actual and expected values and it dispatches on
    # shape internally, so the matcher does not need to know whether it is looking
    # at an object or a collection.
    module SchemaMatch
      module_function

      # Top-level comparison. Applies the shape guards (class equality and, for
      # objects, key-set equality) before recursing.
      def match(actual, expected)
        return false unless actual.instance_of?(expected.class)

        case expected
        when Array
          compare_array(actual, expected)
        when Hash
          return false unless same_key_structure?(actual, expected)

          compare(actual, expected)
        else
          compare_simple_value(actual, expected)
        end
      end

      def same_key_structure?(actual, expected)
        Traversal.deep_sort(Traversal.deep_keys(actual)) ==
          Traversal.deep_sort(Traversal.deep_keys(expected))
      end

      def compare(actual, expected)
        return false unless actual.is_a?(Hash)
        return false if actual.blank? && expected.present?

        keys = Traversal.deep_key_paths(expected) | Traversal.deep_key_paths(actual)

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
        when Class  then compare_class(actual_value, expected_value)
        when Regexp then compare_regexp(actual_value, expected_value)
        when Proc   then compare_proc(actual_value, expected_value)
        when Array  then compare_array(actual_value, expected_value)
        else             compare_simple_value(actual_value, expected_value)
        end
      end

      def compare_class(actual_value, expected_value)
        actual_value.instance_of?(expected_value)
      end

      def compare_regexp(actual_value, expected_value)
        expected_value.match?(actual_value.to_s)
      end

      # A schema Proc describes the constraints for a value; it is called without
      # arguments and must return the option Hash. A Proc that expects the value
      # as an argument is a common misreading of the DSL, and calling it here
      # would raise a bare "wrong number of arguments" from deep in the matcher.
      def compare_proc(actual_value, expected_value)
        if declares_value_parameter?(expected_value)
          raise ArgumentError,
                "schema Proc must take no arguments; " \
                "write -> { { lambda: ->(value) { ... } } } to test the value itself"
        end

        options = expected_value.call
        raise ArgumentError, "schema Proc must return an options Hash, got #{options.class}" unless options.is_a?(Hash)

        Constraints.match(actual_value, options)
      end

      # A non-lambda Proc reports its block parameters as optional, so
      # `proc { |value| ... }` has to be caught on the parameter list rather
      # than on arity. A bare splat states no expectation and is left alone.
      def declares_value_parameter?(callable)
        callable.parameters.any? { |type, _name| %i[req opt keyreq].include?(type) }
      end

      # A list schema only ever matches an actual Array. Without this guard the
      # branches below call Array methods on whatever the response contained, so
      # a null or a scalar where a list was expected raised NoMethodError
      # instead of failing the match.
      def compare_array(actual_value, expected_value)
        return false unless actual_value.is_a?(Array)

        if simple_type?(expected_value)
          compare_typed_array(actual_value, expected_value)
        elsif interface?(expected_value)
          compare_interface_array(actual_value, expected_value)
        else
          compare_exact_array(actual_value, expected_value)
        end
      end

      # [SomeClass] => every element must be an instance of SomeClass.
      def compare_typed_array(actual_value, expected_value)
        type = expected_value[0]

        actual_value.all? { |elem| compare_class(elem, type) }
      end

      # [{ ...interface... }] => every element must match the single interface.
      # Elements go through match (not compare) so each one is held to the same
      # key-structure guard as a top-level object; otherwise an element with an
      # extra null-valued key would slip through (nil == nil).
      def compare_interface_array(actual_value, expected_value)
        interface = expected_value[0]

        actual_value.all? { |elem| match(elem, interface) }
      end

      # Any other array => element-by-element match, sizes must be equal.
      def compare_exact_array(actual_value, expected_value)
        return false if actual_value.size != expected_value.size

        expected_value.each_with_index.all? do |elem, index|
          elem.is_a?(Hash) ? compare(actual_value[index], elem) : compare_values(actual_value[index], elem)
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
