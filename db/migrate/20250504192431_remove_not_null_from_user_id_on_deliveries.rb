class RemoveNotNullFromUserIdOnDeliveries < ActiveRecord::Migration[8.0]
  def up
    change_column_null(:deliveries, :user_id, true) if not_null?(:user_id)
  end

  def down
    if Delivery.where(user_id: nil).exists?
      warn_about_nulls(:user_id)
    else
      change_column_null(:deliveries, :user_id, false)
    end
  end

  private

  def not_null?(column)
    !connection.columns(:deliveries).find { |c| c.name == column.to_s }.null
  end

  def warn_about_nulls(column, table_name)
    puts <<~MSG
      [MIGRATION WARNING] Cannot re-add NOT NULL constraint to :#{column} on #{table_name} because NULL values exist.
      Please clean the data before rerunning this migration.
    MSG
  end

  # Define ActiveRecord model inside migration context for safe querying
  class Delivery < ActiveRecord::Base
    self.table_name = 'deliveries'
  end
end
