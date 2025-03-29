class AddActiveToTrucks < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:trucks, :active)
      add_column :trucks, :active, :boolean, default: true
    end
  end
end
