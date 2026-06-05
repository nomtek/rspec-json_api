# frozen_string_literal: true

module RSpec
  module JsonApi
    # Constraints evaluates the option hash produced by a schema Proc
    # (e.g. `-> { { type: Integer, min: 1, max: 10, allow_blank: true } }`)
    # against an actual value.
    #
    # allow_blank is a modifier, not a constraint of its own: when it is true a
    # blank value is accepted and the remaining options are skipped; otherwise
    # the value is checked against every other option.
    module Constraints
      module_function

      SUPPORTED_OPTIONS = %i[allow_blank type value min max inclusion regex lambda].freeze

      # @param value [Object] the actual value being matched.
      # @param options [Hash] the option hash returned by the schema Proc.
      # @return [Boolean] true when the value satisfies the options.
      # @raise [ArgumentError] when an option key is not supported.
      def match(value, options)
        validate!(options)

        return true if value.blank? && options[:allow_blank]

        options.except(:allow_blank).all? do |option, condition|
          satisfies?(value, option, condition)
        end
      end

      def validate!(options)
        unknown = options.keys - SUPPORTED_OPTIONS
        return if unknown.empty?

        raise ArgumentError, "Unsupported match option(s): #{unknown.join(", ")}"
      end

      def satisfies?(value, option, condition)
        case option
        when :type      then value.instance_of?(condition)
        when :value     then value == condition
        when :inclusion then condition.include?(value)
        when :regex     then condition.match?(value.to_s)
        when :lambda    then condition.call(value)
        when :min, :max then within_bound?(value, option, condition)
        end
      end

      def within_bound?(value, option, condition)
        return false unless value.is_a?(Numeric) && condition.is_a?(Numeric)

        option == :min ? value >= condition : value <= condition
      end
    end
  end
end
