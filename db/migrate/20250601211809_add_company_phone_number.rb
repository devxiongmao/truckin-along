class AddCompanyPhoneNumber < ActiveRecord::Migration[8.0]
  include MigrationHelpers::IdempotentMigration

  def up
    add_column_unless_exists :companies, :phone_number, :string
  end

  def down
    remove_column_if_exists :companies, :phone_number
  end
end
