class CreateShipmentStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :shipment_statuses do |t|
      t.string :name

      t.timestamps
    end
  end
end
