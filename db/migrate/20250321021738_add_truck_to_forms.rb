class AddTruckToForms < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:forms, :truck_id)
      add_reference :forms, :truck, foreign_key: true, null: true
    end
  end
end
