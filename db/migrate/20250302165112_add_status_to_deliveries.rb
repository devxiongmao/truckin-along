class AddStatusToDeliveries < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:deliveries, :status)
      add_column :deliveries, :status, :integer, null: false, default: 0
    end

    add_index :deliveries, :status, if_not_exists: true
  end
end
