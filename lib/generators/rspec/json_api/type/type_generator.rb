# frozen_string_literal: true

module Rspec
  module JsonApi
    module Generators
      class TypeGenerator < Rails::Generators::NamedBase
        source_root File.expand_path("templates", __dir__)

        def copy_interface_file
          create_file "spec/rspec/json_api/types/#{file_name}.rb", <<~FILE
            module RSpec
              module JsonApi
                module Types
                  #{file_name.upcase} = //
                end
              end
            end
          FILE
        end
      end
    end
  end
end
