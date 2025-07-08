class MakeDeliveryIdOptionalInDeliveryShipments < ActiveRecord::Migration[8.0]
  def up
    if column_exists?(:delivery_shipments, :delivery_id)
      change_column_null :delivery_shipments, :delivery_id, true
    end
  end

  def down
    if column_exists?(:delivery_shipments, :delivery_id)
      change_column_null :delivery_shipments, :delivery_id, false
    end
  end
end
