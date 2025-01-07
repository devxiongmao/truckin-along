class AddShipmentStatusToShipments < ActiveRecord::Migration[8.0]
  def change
    add_reference :shipments, :shipment_status, null: false, foreign_key: true
  end
end
