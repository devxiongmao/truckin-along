class AddUserToShipments < ActiveRecord::Migration[8.0]
  def change
    add_reference :shipments, :user, null: true, foreign_key: true
  end
end
