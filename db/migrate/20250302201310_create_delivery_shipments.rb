class CreateDeliveryShipments < ActiveRecord::Migration[8.0]
  def change
    create_table :delivery_shipments, if_not_exists: true do |t|
      t.references :delivery, null: false, foreign_key: true
      t.references :shipment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
