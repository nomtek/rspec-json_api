# frozen_string_literal: true

module Rspec
  module JsonApi
    module Generators
      class InstallGenerator < Rails::Generators::Base
        source_root File.expand_path("templates", __dir__)

        def create_dir_scaffold
          directory "rspec", "spec/rspec"
        end
      end
    end
  end
end
