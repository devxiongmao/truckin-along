class AddDimensionsToShipments < ActiveRecord::Migration[8.0]
  def change
    add_column :shipments, :length, :decimal
    add_column :shipments, :width, :decimal
    add_column :shipments, :height, :decimal
  end
end
