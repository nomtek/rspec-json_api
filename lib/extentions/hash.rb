# frozen_string_literal: true

# Extention methods for hash class
class Hash
  def deep_keys
    each_with_object([]) do |(k, v), keys|
      keys << k
      v = v.schema if v.respond_to?(:schema)
      keys << v.deep_keys if v.respond_to?(:keys)
    end
  end

  def deep_key_paths
    stack = map { |k, v| [[k], v] }
    key_map = []

    until stack.empty?
      key, value = stack.pop

      key_map << key unless value.is_a? Hash

      next unless value.is_a? Hash

      value.map do |k, v|
        stack.push [key.dup << k, v]
      end
    end

    key_map.reverse
  end

  def sanitize!(keys)
    keep_if do |k, _v|
      keys.include?(k)
    end
  end
end
