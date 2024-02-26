# frozen_string_literal: true

require "rspec/json_api/interfaces/example_interface"

RSpec.describe "match_json_schema matcher" do
  shared_examples "correct-match" do
    it "matches expected schema" do
      expect(actual).to match_json_schema(expected)
    end
  end

  shared_examples "incorrect-match" do
    it "does not match expected schema" do
      expect(actual).not_to match_json_schema(expected)
    end
  end

  context "when schema does not match" do
    let(:expected) do
      {
        id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
        name: "Caroline Mayer",
        age: 25,
        children: [
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
            name: "Webster Medina",
            age: 2
          },
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4b",
            name: "Roy Mcdaniel",
            age: 3
          }
        ]
      }
    end

    let(:actual) do
      {
        id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
        name: "Caroline Mayer",
        children: [
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
            name: "Webster Medina",
            age: 2
          },
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4b",
            age: 3
          }
        ]
      }.to_json
    end

    include_examples "incorrect-match"
  end

  context "when redundant argument in expected nested array" do
    let(:expected) do
      {
        id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
        name: "Caroline Mayer",
        age: 25,
        children: [
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
            name: "Webster Medina",
            fav_numbers: [1, 2, 5],
            age: 2
          },
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4b",
            name: "Roy Mcdaniel",
            age: 3
          }
        ]
      }
    end

    let(:actual) do
      {
        id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
        name: "Caroline Mayer",
        age: 25,
        children: [
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
            name: "Webster Medina",
            age: 2
          },
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4b",
            name: "Roy Mcdaniel",
            age: 3
          }
        ]
      }.to_json
    end

    include_examples "incorrect-match"
  end

  context "when redundant argument in actual nested array" do
    let(:expected) do
      {
        id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
        name: "Caroline Mayer",
        age: 25,
        children: [
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
            name: "Webster Medina",
            age: 2
          },
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4b",
            name: "Roy Mcdaniel",
            age: 3
          }
        ]
      }
    end

    let(:actual) do
      {
        id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
        name: "Caroline Mayer",
        age: 25,
        children: [
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
            name: "Webster Medina",
            sex: "Male",
            age: 2
          },
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4b",
            name: "Roy Mcdaniel",
            age: 3
          }
        ]
      }.to_json
    end

    include_examples "incorrect-match"
  end

  context "when exact match given" do
    let(:expected) do
      {
        id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
        name: "Caroline Mayer",
        age: 25,
        children: [
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
            name: "Webster Medina",
            age: 2
          },
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4b",
            name: "Roy Mcdaniel",
            age: 1
          }
        ]
      }
    end

    context "when correct match" do
      let(:actual) do
        {
          id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
          name: "Caroline Mayer",
          age: 25,
          children: [
            {
              id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
              name: "Webster Medina",
              age: 2
            },
            {
              id: "8eccff73-f134-42f2-aed4-751d1f4ebd4b",
              name: "Roy Mcdaniel",
              age: 3
            }
          ]
        }.to_json
      end

      include_examples "correct-match"
    end

    context "when incorrect match" do
      let(:actual) do
        {
          id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
          name: "Caroline Mayer",
          age: 25,
          children: [
            {
              id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
              name: "Webster Medina",
              age: 2
            },
            {
              id: "8eccff73-f134-42f2-aed4-751d1f4ebd4b",
              name: "Roy Mcdaniel",
              age: 5
            }
          ]
        }.to_json
      end

      include_examples "incorrect-match"
    end
  end

  context "when keys are in arbitrary order" do
    let(:expected) do
      {
        id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
        name: "Caroline Mayer",
        age: 25,
        children: [
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
            name: "Webster Medina",
            age: 2
          },
          {
            id: "8eccff73-f134-42f2-aed4-751d1f4ebd4b",
            name: "Roy Mcdaniel",
            age: 3
          }
        ]
      }
    end

    context "when correct match" do
      let(:actual) do
        {
          name: "Caroline Mayer",
          age: 25,
          id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
          children: [
            {
              name: "Webster Medina",
              age: 2,
              id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
            },
            {
              id: "8eccff73-f134-42f2-aed4-751d1f4ebd4b",
              name: "Roy Mcdaniel",
              age: 3
            }
          ]
        }.to_json
      end

      include_examples "correct-match"
    end
  end

  context "when data typed given" do
    let(:expected) do
      {
        id: String,
        name: String,
        age: Integer
      }
    end

    context "when correct match" do
      let(:actual) do
        {
          id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
          name: "Caroline Mayer",
          age: 15
        }.to_json
      end

      include_examples "correct-match"
    end

    context "when incorrect match" do
      let(:actual) do
        {
          id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
          name: 13,
          age: "15"
        }.to_json
      end

      include_examples "incorrect-match"
    end
  end

  context "when custom types given" do
    describe "email" do
      let(:expected) do
        { email: RSpec::JsonApi::Types::EMAIL }
      end

      context "when correct match" do
        let(:actual) do
          { email: "test_test.test+test@test.com" }.to_json
        end

        include_examples "correct-match"
      end

      context "when incorrect match" do
        let(:actual) do
          { email: "+test_test.test+test.com" }.to_json
        end

        include_examples "incorrect-match"
      end
    end

    describe "uri" do
      let(:expected) do
        { uri: RSpec::JsonApi::Types::URI }
      end

      context "when correct match" do
        let(:actual) do
          { uri: "https://example.com/sample?page=10&id=5#section" }.to_json
        end

        include_examples "correct-match"
      end

      context "when incorrect match" do
        let(:actual) do
          { uri: "hxxpsexample.com/sample?page=10&id=5#section" }.to_json
        end

        include_examples "incorrect-match"
      end
    end

    describe "uuid" do
      let(:expected) do
        { uuid: RSpec::JsonApi::Types::UUID }
      end

      context "when correct match" do
        let(:actual) do
          { uuid: "07bbf12b-df44-4c8d-9415-aa33f51c5fc2" }.to_json
        end

        include_examples "correct-match"
      end

      context "when incorrect match" do
        let(:actual) do
          { uuid: "07bbf12b-df44-4c8d-9415-aa33f51c5f" }.to_json
        end

        include_examples "incorrect-match"
      end
    end
  end

  context "when regex given" do
    let(:expected) do
      {
        id: "1",
        hex: /^#([a-fA-F]|[0-9]){3,6}$/
      }
    end

    context "when correct match" do
      let(:actual) do
        {
          id: "1",
          hex: "#FF5733"
        }.to_json
      end

      include_examples "correct-match"
    end

    context "when incorrect match" do
      let(:actual) do
        {
          id: "1",
          hex: "FF?"
        }.to_json
      end

      include_examples "incorrect-match"
    end
  end

  context "when array given" do
    context "when exact match" do
      let(:expected) do
        {
          id: "111",
          numbers: [1, 5, 2, 4, 3]
        }
      end

      context "when correct match" do
        let(:actual) do
          {
            id: "111",
            numbers: [1, 5, 2, 4, 3]
          }.to_json
        end

        include_examples "correct-match"
      end

      context "when incorrect match" do
        let(:actual) do
          {
            id: "111",
            numbers: [1, 5, 2, 4]
          }.to_json
        end

        include_examples "incorrect-match"
      end
    end

    context "when data type" do
      let(:expected) do
        {
          id: "111",
          numbers: Array[Integer]
        }
      end

      context "when correct match" do
        let(:actual) do
          {
            id: "111",
            numbers: [1, 5, 2, 4, 3]
          }.to_json
        end

        include_examples "correct-match"
      end

      context "when incorrect match" do
        let(:actual) do
          {
            id: "111",
            numbers: [1, 5, 2, 4, "x"]
          }.to_json
        end

        include_examples "incorrect-match"
      end
    end
  end

  context "when proc given" do
    context "when type comparison" do
      let(:expected) do
        {
          id: "123123",
          color: -> { { type: String } }
        }
      end

      context "when correct match" do
        let(:actual) do
          {
            id: "123123",
            color: "Blue"
          }.to_json
        end

        include_examples "correct-match"
      end

      context "when incorrect match" do
        let(:actual) do
          {
            id: "111",
            color: 12.5
          }.to_json
        end

        include_examples "incorrect-match"
      end
    end

    context "when value comparison" do
      let(:expected) do
        {
          id: "123123",
          city: -> { { value: "Madrid" } }
        }
      end

      context "when correct match" do
        let(:actual) do
          {
            id: "123123",
            city: "Madrid"
          }.to_json
        end

        include_examples "correct-match"
      end

      context "when incorrect match" do
        let(:actual) do
          {
            id: "111",
            city: "Warsaw"
          }.to_json
        end

        include_examples "incorrect-match"
      end
    end

    context "when inclusion comparison" do
      let(:expected) do
        {
          id: "123123",
          letter: -> { { inclusion: %w[A B C] } }
        }
      end

      context "when correct match" do
        let(:actual) do
          {
            id: "123123",
            letter: "A"
          }.to_json
        end

        include_examples "correct-match"
      end

      context "when incorrect match" do
        let(:actual) do
          {
            id: "111",
            letter: "D"
          }.to_json
        end

        include_examples "incorrect-match"
      end
    end

    context "when min value comparison" do
      let(:expected) do
        {
          id: "123123",
          number: -> { { min: 3 } }
        }
      end

      context "when correct match" do
        let(:actual) do
          {
            id: "123123",
            number: 5
          }.to_json
        end

        include_examples "correct-match"
      end

      context "when incorrect match" do
        let(:actual) do
          {
            id: "123123",
            number: 2
          }.to_json
        end

        include_examples "incorrect-match"
      end
    end

    context "when max value comparison" do
      let(:expected) do
        {
          id: "123123",
          number: -> { { max: 3 } }
        }
      end

      context "when correct match" do
        let(:actual) do
          {
            id: "123123",
            number: 2
          }.to_json
        end

        include_examples "correct-match"
      end

      context "when incorrect match" do
        let(:actual) do
          {
            id: "123123",
            number: 5
          }.to_json
        end

        include_examples "incorrect-match"
      end
    end

    context "when regex comparison" do
      let(:expected) do
        {
          id: "1",
          hex: -> { { regex: /^\#([a-fA-F]|[0-9]){3,6}$/ } }
        }
      end

      context "when correct match" do
        let(:actual) do
          {
            id: "1",
            hex: "#FF5733"
          }.to_json
        end

        include_examples "correct-match"
      end

      context "when incorrect match" do
        let(:actual) do
          {
            id: "1",
            hex: "FF?"
          }.to_json
        end

        include_examples "incorrect-match"
      end
    end

    context "when custom lambda comparison" do
      let(:expected) do
        {
          id: "1",
          number: -> { { lambda: ->(actual) { actual.even? } } }
        }
      end

      context "when correct match" do
        let(:actual) do
          {
            id: "1",
            number: 222
          }.to_json
        end

        include_examples "correct-match"
      end

      context "when incorrect match" do
        let(:actual) do
          {
            id: "1",
            number: 221
          }.to_json
        end

        include_examples "incorrect-match"
      end
    end

    context "when allow_blank option set to true" do
      let(:expected) do
        {
          id: "1",
          name: -> { { value: "John Smith", allow_blank: true } }
        }
      end

      context "when correct match" do
        let(:actual) do
          {
            id: "1",
            name: nil
          }.to_json
        end

        include_examples "correct-match"
      end
    end

    context "when allow_blank option set to false" do
      let(:expected) do
        {
          id: "1",
          name: -> { { value: "John Smith", allow_blank: false } }
        }
      end

      context "when incorrect match" do
        let(:actual) do
          {
            id: "1",
            name: nil
          }.to_json
        end

        include_examples "incorrect-match"
      end
    end
  end

  context "when custom interface given" do
    context "when single interface given" do
      let(:expected) do
        {
          interface: RSpec::JsonApi::Interfaces::EXAMPLE_INTERFACE
        }
      end

      context "when correct match" do
        let(:actual) do
          {
            interface: {
              id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
              name: "John Smith",
              number: 9,
              color: "black"
            }
          }.to_json
        end

        include_examples "correct-match"
      end

      context "when incorrect match" do
        let(:actual) do
          {
            interface: {
              id: 33,
              name: "John Smith",
              number: 9,
              color: "black"
            }
          }.to_json
        end

        include_examples "incorrect-match"
      end
    end

    context "when array given" do
      context "when single interface given" do
        let(:expected) do
          {
            interfaces: Array[RSpec::JsonApi::Interfaces::EXAMPLE_INTERFACE]
          }
        end

        context "when correct match" do
          let(:actual) do
            {
              interfaces: [
                {
                  id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
                  name: "John Smith",
                  number: 9,
                  color: "black"
                },
                {
                  id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
                  name: "John Smith",
                  number: 9,
                  color: nil
                }
              ]
            }.to_json
          end

          include_examples "correct-match"
        end

        context "when incorrect match" do
          let(:actual) do
            {
              interfaces: [
                {
                  id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
                  name: "Anna Smith",
                  number: 9,
                  color: "white"
                },
                {
                  id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
                  name: "John Smith",
                  number: "AAA",
                  color: "black"
                }
              ]
            }.to_json
          end

          include_examples "incorrect-match"
        end
      end
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
              code: %w[+48 0048]
            }
          }
        }
      }.to_json
    end

    let(:expected) do
      {
        id: RSpec::JsonApi::Types::UUID,
        name: "Michal",
        example: RSpec::JsonApi::Interfaces::EXAMPLE_INTERFACE,
        examples: Array[RSpec::JsonApi::Interfaces::EXAMPLE_INTERFACE],
        not_interfaces_array: [
          {
            hash_array: [
              { id: "123123123" },
              { uuid: RSpec::JsonApi::Types::UUID }
            ]
          },
          { id: RSpec::JsonApi::Types::UUID },
          {},
          Array[]
        ],
        email: RSpec::JsonApi::Types::EMAIL,
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
              code: %w[+48 0048]
            }
          }
        }
      }
    end

    include_examples "correct-match"
  end

  context "when JSON schema is array" do
    context "when exact match expected" do
      context "when correct match" do
        let(:actual) do
          [
            {
              id: "100",
              name: "blue"
            },
            {
              id: "101",
              name: "red"
            }
          ].to_json
        end

        let(:expected) do
          [
            {
              id: "100",
              name: "blue"
            },
            {
              id: "101",
              name: "red"
            }
          ]
        end

        include_examples "correct-match"
      end

      context "when incorrect match" do
        let(:actual) do
          [
            {
              id: "100",
              name: "blue"
            },
            {
              id: "101",
              name: "red"
            }
          ].to_json
        end

        let(:expected) do
          [
            {
              id: "100",
              name: "blue"
            },
            {
              id: "101",
              name: "yellow"
            }
          ]
        end

        include_examples "incorrect-match"
      end
    end

    context "when schema expected" do
      context "when empty array" do
        let(:actual) do
          [].to_json
        end

        let(:expected) do
          Array[RSpec::JsonApi::Interfaces::EXAMPLE_INTERFACE]
        end

        include_examples "correct-match"
      end

      context "when correct match" do
        let(:actual) do
          [
            {
              id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
              name: "John Smith",
              number: 9,
              color: "black"
            },
            {
              id: "8eccff73-f134-42f2-aed4-751d1f4ebd4a",
              name: "John Smith",
              number: 9,
              color: nil
            }
          ].to_json
        end

        let(:expected) do
          Array[RSpec::JsonApi::Interfaces::EXAMPLE_INTERFACE]
        end

        include_examples "correct-match"
      end

      context "when incorrect match" do
        let(:actual) do
          [
            {
              id: "8eccff73-f134-42f2-aed4-751d1f4ebd4f",
              name: "John Smith",
              number: 9,
              color: "black"
            },
            {
              name: "John Smith",
              number: 9,
              color: nil
            }
          ].to_json
        end

        let(:expected) do
          Array[RSpec::JsonApi::Interfaces::EXAMPLE_INTERFACE]
        end

        include_examples "incorrect-match"
      end
    end
  end

  context "when JSON schema is array of primitive types" do
    context "when correct match" do
      let(:actual) do
        ["string", 1].to_json
      end

      let(:expected) do
        ["string", 1]
      end

      include_examples "correct-match"
    end

    context "when incorrect match" do
      let(:actual) do
        ["string", 1].to_json
      end

      let(:expected) do
        ["string2", 1]
      end

      include_examples "incorrect-match"
    end
  end
end
