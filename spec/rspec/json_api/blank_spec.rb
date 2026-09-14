# frozen_string_literal: true

RSpec.describe RSpec::JsonApi::Blank do
  describe ".blank?" do
    it "recognizes blank JSON values" do
      [nil, false, "", " \t\n", "\u00A0", [], {}].each do |value|
        expect(described_class.blank?(value)).to be(true), "expected #{value.inspect} to be blank"
      end
    end

    it "rejects present JSON values" do
      [true, 0, "value", [nil], { key: nil }].each do |value|
        expect(described_class.blank?(value)).to be(false), "expected #{value.inspect} to be present"
      end
    end
  end
end
