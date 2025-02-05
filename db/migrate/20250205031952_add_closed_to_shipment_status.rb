class AddClosedToShipmentStatus < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:shipment_statuses, :closed)
      add_column :shipment_statuses, :closed, :boolean, default: false, null: false
    end
  end
end
