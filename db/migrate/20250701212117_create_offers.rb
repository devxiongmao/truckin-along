class CreateOffers < ActiveRecord::Migration[8.0]
  def change
    create_table :offers, if_not_exists: true do |t|
      t.references :shipment, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.text :reception_address
      t.boolean :pickup_from_sender, default: false, null: false
      t.boolean :deliver_to_door, default: true, null: false
      t.text :dropoff_location
      t.boolean :pickup_at_dropoff, default: false, null: false
      t.float :price, null: false
      t.text :notes

      t.timestamps
    end
  end
end
