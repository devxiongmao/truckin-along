class RemoveBoxesFromShipments < ActiveRecord::Migration[8.0]
  def up
    if column_exists?(:shipments, :boxes)
      remove_column :shipments, :boxes
    end
  end

  def down
    unless column_exists?(:shipments, :boxes)
      add_column :shipments, :boxes, :integer
    end
  end
end
