class RemoveDeletedAtColumns < ActiveRecord::Migration[8.0]
  include MigrationHelpers::IdempotentMigration

  def up
    remove_column_if_exists :trucks, :deleted_at
    remove_column_if_exists :shipments, :deleted_at
  end

  def down
    add_column_unless_exists :trucks, :deleted_at, :datetime
    add_column_unless_exists :shipments, :deleted_at, :datetime
  end
end
