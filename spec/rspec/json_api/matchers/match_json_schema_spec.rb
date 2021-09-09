# frozen_string_literal: true

RSpec.describe "match_json_schema matcher" do
  context "when mixed expected schema" do
    let(:actual) do
      {
        id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
        name: "Michal",
        example: {
          id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
          name: "TestName",
          number: 1,
          color: "black"
        },
        examples: [
                    {
                      id: "8eccff73-f134-42f2-aed4-751d1f4ebd4b",
                      name: "TestName2",
                      number: 2,
                      color: "red"
                    },
                    {
                      id: "8eccff73-f134-42f2-aed4-751d1f4ebd4b",
                      name: "TestName3",
                      number: 3,
                      color: "white"
                    },
        ],
        email: "test@test.com",
        sex: "Male",
        height: 170,
        age: 21,
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
        example: Rspec::JsonApi::Interfaces::ExampleInterface,
        examples: Array[Rspec::JsonApi::Interfaces::ExampleInterface],
        email: Rspec::JsonApi::Types::EMAIL,
        sex: -> { { inclusion: %w[Male Female] } },
        height: -> { { type: Integer, lambda: ->(actual) { actual.even? } } },
        age: -> { { type: Integer, min: 1, max: 100 } },
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

    it "matches expected schema" do
      expect(actual).to match_json_schema(expected)
    end
  end
end
