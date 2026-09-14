# frozen_string_literal: true

RSpec.describe RSpec::JsonApi::SchemaMatch do
  describe ".match" do
    where = [
      ["matches a root Class schema", "value", String, true],
      ["rejects the wrong type for a root Class schema", 1, String, false],
      ["matches a root Regexp schema", "abc-123", /\A[a-z]+-\d+\z/, true],
      ["rejects a non-String for a root Regexp schema", 123, /\A\d+\z/, false],
      ["matches a root literal", 123, 123, true],
      ["rejects a different root literal", 123, 456, false]
    ]

    where.each do |description, actual, expected, result|
      it description do
        expect(described_class.match(actual, expected)).to be(result)
      end
    end

    it "rejects an extra null-valued key inside an exact array" do
      actual = [{ id: 1, extra: nil }, { id: 2 }]
      expected = [{ id: Integer }, { id: Integer }]

      expect(described_class.match(actual, expected)).to be(false)
    end

    it "rejects a missing allow-blank key inside an exact array" do
      actual = [{ id: 1 }, { id: 2 }]
      expected = [
        { id: Integer, name: -> { { type: String, allow_blank: true } } },
        { id: Integer }
      ]

      expect(described_class.match(actual, expected)).to be(false)
    end

    it "rejects nested keys attached to different parents" do
      actual = { primary: { id: nil }, secondary: { name: nil } }
      expected = { primary: { name: nil }, secondary: { id: nil } }

      expect(described_class.match(actual, expected)).to be(false)
    end

    it "rejects nested keys attached to different parents inside an exact array" do
      actual = [{ primary: { id: nil }, secondary: { name: nil } }, { id: 1 }]
      expected = [{ primary: { name: nil }, secondary: { id: nil } }, { id: Integer }]

      expect(described_class.match(actual, expected)).to be(false)
    end

    it "rejects a non-String value for a nested Regexp schema" do
      expect(described_class.match({ code: 123 }, { code: /\A\d+\z/ })).to be(false)
    end

    it "rejects nil for a nested permissive Regexp schema" do
      expect(described_class.match({ code: nil }, { code: /.*/ })).to be(false)
    end
  end
end
