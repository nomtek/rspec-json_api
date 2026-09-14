# frozen_string_literal: true

require "logger"
require "rails/generators"
require "tmpdir"

RSpec.describe "RSpec::JsonApi generators", :generator do
  around do |example|
    Dir.mktmpdir("rspec-json-api-generators") do |destination|
      @destination_root = destination
      example.run
    end
  end

  it "installs the type and interface directories" do
    Rails::Generators.invoke("rspec:json_api:install", [], destination_root: @destination_root)

    expect(File).to exist(File.join(@destination_root, "spec/rspec/json_api/types"))
    expect(File).to exist(File.join(@destination_root, "spec/rspec/json_api/interfaces"))
  end

  it "generates a frozen interface constant" do
    Rails::Generators.invoke("rspec:json_api:interface", ["person"], destination_root: @destination_root)

    generated = File.read(File.join(@destination_root, "spec/rspec/json_api/interfaces/person.rb"))
    expect(generated).to include("PERSON = {", "}.freeze", "# frozen_string_literal: true")
  end

  it "generates a type constant" do
    Rails::Generators.invoke("rspec:json_api:type", ["color_hex"], destination_root: @destination_root)

    generated = File.read(File.join(@destination_root, "spec/rspec/json_api/types/color_hex.rb"))
    expect(generated).to include("COLOR_HEX = //", "# frozen_string_literal: true")
  end
end
