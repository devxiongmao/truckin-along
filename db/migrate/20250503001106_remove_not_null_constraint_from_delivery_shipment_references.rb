class RemoveNotNullConstraintFromDeliveryShipmentReferences < ActiveRecord::Migration[8.0]
  def up
    change_column_null(:delivery_shipments, :shipment_id, true) if not_null?(:shipment_id)
    change_column_null(:delivery_shipments, :delivery_id, true) if not_null?(:delivery_id)
  end

  def down
    if DeliveryShipment.where(shipment_id: nil).exists?
      warn_about_nulls(:shipment_id)
    else
      change_column_null(:delivery_shipments, :shipment_id, false)
    end

    if DeliveryShipment.where(delivery_id: nil).exists?
      warn_about_nulls(:delivery_id)
    else
      change_column_null(:delivery_shipments, :delivery_id, false)
    end
  end

  private

  def not_null?(column)
    !connection.columns(:delivery_shipments).find { |c| c.name == column.to_s }.null
  end

  def warn_about_nulls(column)
    puts <<~MSG
      [MIGRATION WARNING] Cannot re-add NOT NULL constraint to :#{column} on delivery_shipments because NULL values exist.
      Please clean the data before rerunning this migration.
    MSG
  end

  # Define ActiveRecord model inside migration context for safe querying
  class DeliveryShipment < ActiveRecord::Base
    self.table_name = 'delivery_shipments'
  end
end
