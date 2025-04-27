module MigrationHelpers
  module IdempotentMigration
    def add_column_unless_exists(table_name, column_name, type, **options)
      unless column_exists?(table_name, column_name)
        add_column(table_name, column_name, type, **options)
      end
    end

    def remove_column_if_exists(table_name, column_name)
      if column_exists?(table_name, column_name)
        remove_column(table_name, column_name)
      end
    end
  end
end
