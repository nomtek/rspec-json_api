# frozen_string_literal: true

require "rspec/expectations"
require "hash"
require "json"

RSpec::Matchers.define :match_json_schema do |expected|
  match do |actual|
    # Parse JSON object into hash
    actual = JSON.parse(actual, symbolize_names: true)

    # Compare keys schema
    return false unless actual.deep_keys == expected.deep_keys

    # Compare respond with gicen schema
    return false unless compare(actual, expected)

    true
  end

  def compare(actual, expected)
    key_paths = actual.get_deep_key_paths

    key_paths.all? do |key_path|
      actual_value = actual.dig(*key_path)
      expected_value = expected.dig(*key_path)

      compare_hash_values(actual_value, expected_value)
    end
  end

  SUPPORTED_OPTIONS = %i[type value min max inclusion regex lambda].freeze

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

      actual_value.all? { |elem| elem.instance_of?(type) }
    else
      compare_value(actual_value, expected_value)
    end
  end

  def compare_value(actual_value, expected_value)
    actual_value == expected_value
  end

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
end

RSpec.describe "" do
  let(:actual) do
    {
      id: "5",
      name: "Michal",
      sex: "Male",
      height: 170,
      age: 21,
      preferences: {
        id: "6",
        color: "blue",
        address: {
          city: [1, 2, 3],
          zip: {
            sym: "PL",
            code: ["+48", "0048"]
          }
        }
      }
    }.to_json
  end

  let(:expected) do
    {
      id: "5",
      name: String,
      sex: -> { { inclusion: %w[Male Female] } },
      height: -> { { type: Integer, lambda: ->(actual) { actual.even? } } },
      age: -> { { type: Integer, min: 1, max: 100 } },
      preferences: {
        id: "6",
        color: /^bl.*$/,
        address: {
          city: Array[Integer],
          zip: {
            sym: "PL",
            code: ["+48", "0048"]
          }
        }
      }
    }
  end

  it "" do
    expect(actual).to match_json_schema(expected)
  end
end
