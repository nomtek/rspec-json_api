# frozen_string_literal: true

RSpec.describe RSpec::JsonApi::Constraints do
  describe ".match" do
    it "raises ArgumentError for an unsupported option" do
      expect { described_class.match("value", bogus: 1) }
        .to raise_error(ArgumentError, /Unsupported match option/)
    end

    it "raises ArgumentError when the options are not a Hash" do
      expect { described_class.match("value", true) }
        .to raise_error(ArgumentError, /must return an options Hash/)
    end

    it "accepts a blank value when allow_blank is true" do
      expect(described_class.match(nil, value: "John", allow_blank: true)).to be(true)
    end

    it "rejects a blank value that fails a companion constraint when allow_blank is false" do
      expect(described_class.match(nil, value: "John", allow_blank: false)).to be(false)
    end

    it "checks remaining constraints when the value is present" do
      expect(described_class.match(5, type: Integer, min: 3, max: 10)).to be(true)
      expect(described_class.match(2, type: Integer, min: 3)).to be(false)
    end
  end
end
