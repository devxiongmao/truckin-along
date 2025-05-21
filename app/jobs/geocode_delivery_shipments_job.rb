class GeocodeDeliveryShipmentsJob < ApplicationJob
  queue_as :default
  retry_on StandardError, attempts: 5, wait: :exponentially_longer

  def perform(ids)
    DeliveryShipment.where(id: ids).find_each do |shipment|
      updates = {}

      begin
        if shipment.sender_address.present?
          result = safe_geocode(shipment.sender_address)
          if result
            updates[:sender_latitude] = result.latitude
            updates[:sender_longitude] = result.longitude
          end
        end

        if shipment.receiver_address.present?
          result = safe_geocode(shipment.receiver_address)
          if result
            updates[:receiver_latitude] = result.latitude
            updates[:receiver_longitude] = result.longitude
          end
        end

        shipment.update_columns(updates) if updates.present?
      rescue => e
        Rails.logger.error("Geocoding failed for DeliveryShipment ##{shipment.id}: #{e.message}")
        raise e
      end
    end
  end

  private

  def safe_geocode(address)
    Geocoder.search(address).first
  rescue Geocoder::OverQueryLimitError => e
    Rails.logger.warn("Rate limited by Geocoder for address: #{address}")
    raise e
  rescue StandardError => e
    Rails.logger.error("Unexpected geocode error for address #{address}: #{e.message}")
    raise e
  end
end
