# frozen_string_literal: true

RSpec.describe "match_json_schema matcher" do
  shared_examples "correct-match" do
    it "matches expected schema" do
      expect(actual).to match_json_schema(expected)
    end
  end

  shared_examples "incorrect-match" do
    it "does not matche expected schema" do
      expect(actual).not_to match_json_schema(expected)
    end
  end

  context 'when exact match' do
    let(:expected) do
      {
        id: '8eccff73-f134-42f2-aed4-751d1f4ebd4f',
        name: 'Caroline Mayer',
        age: 15
      }
    end

    context 'when correct match' do
      let(:actual) do
        {
          id: '8eccff73-f134-42f2-aed4-751d1f4ebd4f',
          name: 'Caroline Mayer',
          age: 15
        }.to_json
      end

      include_examples 'correct-match'
    end

    context 'when incorrect match' do
      let(:actual) do
        {
          id: '8eccff73-f134-42f2-aed4-751d1f4ebd4f',
          name: 'Caroline Mayer',
          age: 16
        }.to_json
      end

      include_examples 'incorrect-match'
    end
  end

  context 'when typed schema' do
    let(:expected) do
      {
        id: String,
        name: String,
        age: Integer
      }
    end

    context 'when correct match' do
      let(:actual) do
        {
          id: '8eccff73-f134-42f2-aed4-751d1f4ebd4f',
          name: 'Caroline Mayer',
          age: 15
        }.to_json
      end

      include_examples 'correct-match'
    end

    context 'when incorrect match' do
      let(:actual) do
        {
          id: '8eccff73-f134-42f2-aed4-751d1f4ebd4f',
          name: 13,
          age: '15'
        }.to_json
      end

      include_examples 'incorrect-match'
    end
  end

  context "when complex mixed schema" do
    let(:actual) do
      {
        id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
        name: "Michal",
        example: {
          id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
          name: "TestName",
          number: 1,
          color: "red"
        },
        examples: [
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
            name: "TestName",
            number: 1,
            color: "red"
          },
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
            name: "TestName2",
            number: 2,
            color: nil
          }
        ],
        not_interfaces_array: [
          {
            hash_array: [
              { id: "123123123" },
              { uuid: "8eccff73-f134-42f2-aed4-751d1f4ebd4a" }
            ]
          },
          { id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a" },
          {},
          []
        ],
        email: "test@test.com",
        sex: "Male",
        height: 170,
        age: 50,
        preferences: {
          id: "6",
          color: "blue",
          address: {
            city: [1, 2, 3],
            zip: {
              sym: "PL",
              code: ["+48", "0048"]
            }
          }
        }
      }.to_json
    end

    let(:expected) do
      {
        id: Rspec::JsonApi::Types::UUID,
        name: "Michal",
        example: Rspec::JsonApi::Interfaces::EXAMPLE_INTERFACE,
        examples: Array[Rspec::JsonApi::Interfaces::EXAMPLE_INTERFACE],
        not_interfaces_array: [
          {
            hash_array: [
              { id: "123123123" },
              { uuid: Rspec::JsonApi::Types::UUID }
            ]
          },
          { id: Rspec::JsonApi::Types::UUID },
          {},
          Array[]
        ],
        email: Rspec::JsonApi::Types::EMAIL,
        sex: -> { { inclusion: %w[Male Female] } },
        height: -> { { type: Integer, lambda: ->(actual) { actual.even? } } },
        age: -> { { type: Integer, min: 1, max: 100, allow_blank: false } },
        preferences: {
          id: "6",
          color: /^bl.*$/,
          address: {
            city: Array[Integer],
            zip: {
              sym: "PL",
              code: ["+48", "0048"]
            }
          }
        }
      }
    end

    include_examples 'correct-match'
  end
end
