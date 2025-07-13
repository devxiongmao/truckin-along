class DeliveryShipment < ApplicationRecord
  belongs_to :delivery, optional: true
  belongs_to :shipment

  has_one :rating, dependent: :destroy

  after_validation :geocode_sender, if: ->(obj) { obj.sender_address.present? && obj.sender_address_changed? }
  after_validation :geocode_receiver, if: ->(obj) { obj.receiver_address.present? && obj.receiver_address_changed? }

  private

  def geocode_sender
    # Skip geocoding if coordinates were manually set
    return if sender_latitude_changed? || sender_longitude_changed?

    result = Geocoder.search(sender_address).first
    if result
      self.sender_latitude = result.latitude
      self.sender_longitude = result.longitude
    end
  end

  def geocode_receiver
    # Skip geocoding if coordinates were manually set
    return if receiver_latitude_changed? || receiver_longitude_changed?

    result = Geocoder.search(receiver_address).first
    if result
      self.receiver_latitude = result.latitude
      self.receiver_longitude = result.longitude
    end
  end
end
