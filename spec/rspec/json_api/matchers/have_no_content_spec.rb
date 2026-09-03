# frozen_string_literal: true

RSpec.describe "have_no_content matcher" do
  context "when an empty string is given" do
    let(:actual) { "" }

    it "matches" do
      expect(actual).to have_no_content
    end
  end

  context "when a non-empty string is given" do
    # Each value needs its own context: declaring let(:actual) more than once in
    # a single context makes the last declaration win, so the earlier values
    # would never be exercised.
    ["{}", "[]", '{"id":1}', " "].each do |actual_value|
      context "when the body is #{actual_value.inspect}" do
        let(:actual) { actual_value }

        it "does not match" do
          expect(actual).not_to have_no_content
        end
      end
    end
  end
end
