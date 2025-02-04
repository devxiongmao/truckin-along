class AddLockedForCustomersToShipmentStatuses < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:shipment_statuses, :locked_for_customers)
      add_column :shipment_statuses, :locked_for_customers, :boolean, default: false, null: false
    end
  end
end
