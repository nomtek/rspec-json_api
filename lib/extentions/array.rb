# frozen_string_literal: true

class Array
  def deep_sort
    map { |element| element.is_a?(Array) ? element.deep_sort : element }
      .sort_by { |el| el.is_a?(Array) ? el.first.to_s : el.to_s }
  end
end