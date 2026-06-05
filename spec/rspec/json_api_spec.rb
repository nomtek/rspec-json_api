# frozen_string_literal: true

RSpec.describe RSpec::JsonApi do
  it "has a version number" do
    expect(RSpec::JsonApi::VERSION).not_to be nil
  end

  it "does not monkey-patch core Hash and Array" do
    expect({}).not_to respond_to(:deep_keys, :deep_key_paths, :sanitize!)
    expect([]).not_to respond_to(:deep_sort)
  end
end
