# frozen_string_literal: true

module RSpec
  module JsonApi
    module Generators
      class InterfaceGenerator < Rails::Generators::NamedBase
        source_root File.expand_path("templates", __dir__)

        def copy_interface_file
          copy_file "interface.rb", "spec/rspec/json_api/interfaces/#{file_name}.rb"
        end
      end
    end
  end
end
