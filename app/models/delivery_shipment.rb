class DeliveryShipment < ApplicationRecord
  belongs_to :delivery, optional: true
  belongs_to :shipment

  after_validation :geocode_sender, if: ->(obj) { obj.sender_address.present? && obj.sender_address_changed? }
  after_validation :geocode_receiver, if: ->(obj) { obj.receiver_address.present? && obj.receiver_address_changed? }

  private

  def geocode_sender
    result = Geocoder.search(sender_address).first
    if result
      self.sender_latitude = result.latitude
      self.sender_longitude = result.longitude
    end
  end

  def geocode_receiver
    result = Geocoder.search(receiver_address).first
    if result
      self.receiver_latitude = result.latitude
      self.receiver_longitude = result.longitude
    end
  end
end
