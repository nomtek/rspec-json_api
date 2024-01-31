# frozen_string_literal: true

RSpec.describe "match_empty_body matcher" do
  context "when empty value is given" do
    let(:actual) { "" }

    it "matches expected schema" do
      expect(actual).to have_no_content
    end
  end

  context "when non-empty value is given" do
    %w[{} []].each do |actual_value|
      let(:actual) { actual_value }

      it "matches expected schema" do
        expect(actual).not_to have_no_content
      end
    end
  end
end
