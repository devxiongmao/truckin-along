class MakeTruckAndUserOptionalInDeliveries < ActiveRecord::Migration[8.0]
  def change
    if column_exists?(:deliveries, :truck_id) && !column_nullable?(:deliveries, :truck_id)
      change_column_null :deliveries, :truck_id, true
    end

    if column_exists?(:deliveries, :user_id) && !column_nullable?(:deliveries, :user_id)
      change_column_null :deliveries, :user_id, true
    end
  end

  private

  def column_nullable?(table, column)
    connection = ActiveRecord::Base.connection
    column_info = connection.columns(table).find { |c| c.name == column.to_s }
    column_info.null
  end
end
