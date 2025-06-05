module ShipmentsHelper
  def auto_select_sender(shipment)
    if current_user && current_user.role == "customer"
      current_user&.display_name
    else
      shipment.sender_name
    end
  end

  def auto_select_address(shipment)
    if current_user && current_user.role == "customer" && shipment.sender_address.blank?
      current_user&.home_address
    else
      shipment.sender_address
    end
  end

  def locked_fields?(shipment_status)
    return true if shipment_status&.closed
    return true if current_user && current_user.role == "customer" && shipment_status&.locked_for_customers
    false
  end

  def lock_fields_by_role(field)
    whitelisted_fields = {
      customer: %i[name sender_name sender_address receiver_name receiver_address weight length width height deliver_by],
      admin: %i[shipment_status_id sender_address receiver_address weight length width height],
      driver: %i[shipment_status_id weight length width height]
    }

    current_user_role = current_user.role.to_sym
    !whitelisted_fields.fetch(current_user_role, []).include?(field)
  end

  def back_link_path(user, shipment)
    return shipments_path if user.customer?
    return load_truck_deliveries_path if shipment.claimed? && shipment.truck_id.nil?
    return start_deliveries_path if shipment.claimed? && !shipment.truck_id.nil?

    deliveries_path
  end

  def prep_delivery_shipments_json(shipment)
    shipment.delivery_shipments.map do |delivery_shipment|
      {
        senderLat: delivery_shipment.sender_latitude,
        senderLng: delivery_shipment.sender_longitude,
        receiverLat: delivery_shipment.receiver_latitude,
        receiverLng: delivery_shipment.receiver_longitude,
        senderAddress: delivery_shipment.sender_address,
        receiverAddress: delivery_shipment.receiver_address
      }
    end.to_json
  end
end
