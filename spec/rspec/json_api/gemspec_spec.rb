# frozen_string_literal: true

RSpec.describe "rspec-json_api.gemspec" do
  subject(:gemspec) do
    Gem::Specification.load(File.join(repo_root, "rspec-json_api.gemspec"))
  end

  let(:repo_root) { File.expand_path("../../..", __dir__) }

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

  it "packages every tracked file under lib and nothing else from there" do
    tracked_lib = Dir.chdir(repo_root) { `git ls-files -z lib`.split("\x0").sort }

    expect(gemspec.files.grep(%r{\Alib/})).to eq(tracked_lib)
  end

  it "packages nothing outside lib but the licence and the reference documents" do
    expect(gemspec.files.grep_v(%r{\Alib/})).to contain_exactly("CHANGELOG.md", "LICENSE.txt", "README.md")
  end
end
