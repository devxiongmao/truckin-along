class CreateShipmentActionPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :shipment_action_preferences, if_not_exists: true do |t|
      t.string :action
      t.references :company, null: false, foreign_key: true
      t.references :shipment_status, null: true, foreign_key: true

      t.timestamps
    end
  end
end
