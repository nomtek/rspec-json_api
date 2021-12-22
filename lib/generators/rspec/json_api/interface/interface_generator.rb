# frozen_string_literal: true

module Rspec
  module JsonApi
    module Generators
      class InterfaceGenerator < Rails::Generators::NamedBase
        source_root File.expand_path("templates", __dir__)

        def copy_interface_file
          create_file "spec/rspec/json_api/interfaces/#{file_name}.rb", <<~FILE
            module RSpec
              module JsonApi
                module Interfaces
                  #{file_name.upcase} = {
                    # name: String
                  }
                end
              end
            end
          FILE
        end
      end
    end
  end
end
