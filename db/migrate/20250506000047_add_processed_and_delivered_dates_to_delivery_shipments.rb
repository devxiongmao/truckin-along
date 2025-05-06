class AddProcessedAndDeliveredDatesToDeliveryShipments < ActiveRecord::Migration[8.0]
  include MigrationHelpers::IdempotentMigration

  def up
    add_column_unless_exists :delivery_shipments, :loaded_date, :datetime
    add_column_unless_exists :delivery_shipments, :delivered_date, :datetime
  end

  def down
    remove_column_if_exists :delivery_shipments, :loaded_date
    remove_column_if_exists :delivery_shipments, :delivered_date
  end
end
