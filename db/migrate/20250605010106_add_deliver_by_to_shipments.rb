class AddDeliverByToShipments < ActiveRecord::Migration[8.0]
  include MigrationHelpers::IdempotentMigration

  def up
    add_column_unless_exists :shipments, :deliver_by, :date
  end

  def down
    remove_column_if_exists :shipments, :deliver_by
  end
end
