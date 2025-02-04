class RemoveNotNullConstraintFromShipmentStatusIdOnShipments < ActiveRecord::Migration[8.0]
  def up
    change_column_null :shipments, :shipment_status_id, true
  end

  def down
    change_column_null :shipments, :shipment_status_id, false
  end
end
