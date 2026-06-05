# frozen_string_literal: true

module RSpec
  module JsonApi
    # Traversal holds the structural helpers used to compare JSON shapes:
    # collecting the nested key structure of a Hash and sorting it into a
    # canonical order. These were previously monkey-patched onto core Hash and
    # Array; keeping them here means the gem no longer mutates those classes in
    # the host application.
    module Traversal
      module_function

      # The nested keys of a hash, with each nested hash's keys inlined as an
      # array, e.g. { a: 1, b: { c: 2 } } => [:a, :b, [:c]].
      def deep_keys(hash)
        hash.each_with_object([]) do |(key, value), keys|
          keys << key
          keys << deep_keys(value) if value.respond_to?(:keys)
        end
      end

      # Every leaf key path of a hash, e.g. { a: { b: 1 }, c: 2 } => [[:a, :b], [:c]].
      def deep_key_paths(hash)
        stack = hash.map { |key, value| [[key], value] }
        key_map = []

        until stack.empty?
          key, value = stack.pop

          key_map << key unless value.is_a?(Hash)

          next unless value.is_a?(Hash)

          value.each { |k, v| stack.push([key.dup << k, v]) }
        end

        key_map.reverse
      end

      # Recursively sorts an array (and any nested arrays) into a canonical order
      # so two key structures can be compared regardless of original order.
      def deep_sort(array)
        array
          .map { |element| element.is_a?(Array) ? deep_sort(element) : element }
          .sort_by { |element| element.is_a?(Array) ? element.first.to_s : element.to_s }
      end
    end
  end
end
