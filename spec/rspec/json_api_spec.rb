# frozen_string_literal: true

require "open3"
require "rbconfig"

RSpec.describe RSpec::JsonApi do
  it "has a version number" do
    expect(RSpec::JsonApi::VERSION).not_to be nil
  end

  it "does not monkey-patch core Hash and Array" do
    expect({}).not_to respond_to(:deep_keys, :deep_key_paths, :sanitize!)
    expect([]).not_to respond_to(:deep_sort)
  end

  it "does not load ActiveSupport core extensions" do
    script = <<~RUBY
      require "rspec/json_api"
      abort "ActiveSupport core extensions loaded" if Object.new.respond_to?(:blank?)
    RUBY

    _stdout, stderr, status = Open3.capture3(RbConfig.ruby, "-Ilib", "-e", script)

    expect(status).to be_success, stderr
  end
end
