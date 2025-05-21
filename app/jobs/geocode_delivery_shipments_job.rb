class GeocodeDeliveryShipmentsJob < ApplicationJob
  queue_as :default

  def perform(ids)
    DeliveryShipment.where(id: ids).find_each do |shipment|
      updates = {}

      if shipment.sender_address.present?
        sender_result = Geocoder.search(shipment.sender_address).first
        if sender_result
          updates[:sender_latitude] = sender_result.latitude
          updates[:sender_longitude] = sender_result.longitude
        end
      end

      if shipment.receiver_address.present?
        receiver_result = Geocoder.search(shipment.receiver_address).first
        if receiver_result
          updates[:receiver_latitude] = receiver_result.latitude
          updates[:receiver_longitude] = receiver_result.longitude
        end
      end

      shipment.update_columns(updates) if updates.present?
    end
  end
end
