class CreateDeliveries < ActiveRecord::Migration[8.0]
  def change
    create_table :deliveries, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true
      t.references :truck, null: false, foreign_key: true

      t.timestamps
    end
  end
end
