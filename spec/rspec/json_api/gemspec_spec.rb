# frozen_string_literal: true

RSpec.describe "rspec-json_api.gemspec" do
  subject(:gemspec) do
    Gem::Specification.load(File.expand_path("../../../rspec-json_api.gemspec", __dir__))
  end

  it "packages the library" do
    expect(gemspec.files).to include("lib/rspec/json_api.rb", "lib/rspec/json_api/version.rb")
  end

  it "packages the generator templates, including the empty-directory markers" do
    expect(gemspec.files).to include(
      "lib/generators/rspec/json_api/install/install_generator.rb",
      "lib/generators/rspec/json_api/install/templates/rspec/json_api/types/.empty_directory",
      "lib/generators/rspec/json_api/install/templates/rspec/json_api/interfaces/.empty_directory"
    )
  end

  it "packages the licence and the reference documents" do
    expect(gemspec.files).to include("LICENSE.txt", "README.md", "CHANGELOG.md")
  end

  it "does not package repository tooling" do
    expect(gemspec.files).not_to include(
      ".github/workflows/main.yml", ".rubocop.yml", ".gitignore", "Gemfile", "Gemfile.lock", "Rakefile"
    )
  end

  it "does not package the spec suite, the appraisals or the roadmap" do
    expect(gemspec.files.grep(%r{\A(spec|gemfiles|bin)/})).to be_empty
    expect(gemspec.files).not_to include("ROADMAP.md")
  end
end
