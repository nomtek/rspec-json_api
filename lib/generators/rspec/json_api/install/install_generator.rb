# frozen_string_literal: true

module RSpec
  module JsonApi
    module Generators
      class InstallGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)

        def create_dir_scaffold
          directory "rspec"
        end
      end
    end
  end
end
