class DropStatusFromShipments < ActiveRecord::Migration[8.0]
  def change
    remove_column :shipments, :status, if_exists: true
  end
end
