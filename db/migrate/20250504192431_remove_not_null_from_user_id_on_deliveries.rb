class RemoveNotNullFromUserIdOnDeliveries < ActiveRecord::Migration[8.0]
  def up
    change_column_null(:deliveries, :user_id, true) if not_null?(:user_id)
  end

  def down
    if Delivery.where(user_id: nil).exists?
      raise ActiveRecord::IrreversibleMigration, <<~MSG
        Cannot re-add NOT NULL constraint to :user_id on deliveries because NULL values exist.
        Please clean the data before rerunning this migration.
      MSG
    else
      change_column_null(:deliveries, :user_id, false)
    end
  end

  private

  def not_null?(column)
    !connection.columns(:deliveries).find { |c| c.name == column.to_s }.null
  end

  # Define lightweight model inside migration
  class Delivery < ActiveRecord::Base
    self.table_name = 'deliveries'
  end
end
