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
    if current_user && current_user.role == "customer" && shipment_status&.locked_for_customers
      true
    else
      false
    end
  end
end
