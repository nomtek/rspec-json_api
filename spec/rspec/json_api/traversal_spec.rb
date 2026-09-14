# frozen_string_literal: true

RSpec.describe RSpec::JsonApi::Traversal do
  describe ".deep_keys" do
    it "collects nested object keys" do
      expect(described_class.deep_keys({ id: 1, profile: { name: "Ada" } }))
        .to eq([:id, :profile, [:name]])
    end
  end

  describe ".deep_key_paths" do
    it "returns every leaf path" do
      value = { id: 1, profile: { name: "Ada", tags: ["ruby"] } }

      expect(described_class.deep_key_paths(value))
        .to contain_exactly([:id], %i[profile name], %i[profile tags])
    end
  end

  describe ".deep_sort" do
    it "sorts nested key collections recursively" do
      expect(described_class.deep_sort([:z, %i[c b], :a]))
        .to eq([:a, %i[b c], :z])
    end
  end
end
