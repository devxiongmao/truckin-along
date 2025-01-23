class AddDimensionsAndWeightToTrucks < ActiveRecord::Migration[8.0]
  def change
    add_column :trucks, :length, :decimal
    add_column :trucks, :width, :decimal
    add_column :trucks, :height, :decimal
    add_column :trucks, :weight, :decimal
  end
end
