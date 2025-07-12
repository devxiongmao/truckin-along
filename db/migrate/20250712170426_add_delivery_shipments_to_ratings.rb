class AddDeliveryShipmentsToRatings < ActiveRecord::Migration[8.0]
  def up
    unless column_exists?(:ratings, :delivery_shipment_id)
      add_reference :ratings, :delivery_shipment, null: false, foreign_key: true
    end
  end

  def down
    if column_exists?(:ratings, :delivery_shipment_id)
      remove_reference :ratings, :delivery_shipment, foreign_key: true
    end
  end
end
