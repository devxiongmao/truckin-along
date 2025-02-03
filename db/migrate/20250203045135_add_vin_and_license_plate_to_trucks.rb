class AddVinAndLicensePlateToTrucks < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:trucks, :vin)
      add_column :trucks, :vin, :string, null: false
    end

    unless column_exists?(:trucks, :license_plate)
      add_column :trucks, :license_plate, :string, null: false
    end
  end
end
