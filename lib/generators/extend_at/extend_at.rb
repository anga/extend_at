require 'rails/generators/base'

module ExtendAt
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('./templates', __FILE__)
      desc "Generate all necesaries models and migrations for extend_at gem"

      def self.next_migration_number(path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def create_model
        template "integer_value.rb", "app/models/integer_value.rb"
        template "float_value.rb", "app/models/float_value.rb"
        template "string_value.rb", "app/models/string_value.rb"
        template "text_value.rb", "app/models/any_value.rb"
        template "any_value.rb", "app/models/any_value.rb"
        migration_template "create_extend_at_tables.rb", "db/migrate/create_extend_at_tables.rb"
      end
    end
  end
end
