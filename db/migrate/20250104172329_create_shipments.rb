class CreateShipments < ActiveRecord::Migration[8.0]
  def change
    create_table :shipments do |t|
      t.string :name
      t.string :status
      t.string :sender_name
      t.text :sender_address
      t.string :receiver_name
      t.text :receiver_address
      t.decimal :weight
      t.integer :boxes
      t.references :truck, null: true, foreign_key: true

      t.timestamps
    end
  end
end
