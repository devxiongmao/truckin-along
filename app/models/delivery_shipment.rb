class DeliveryShipment < ApplicationRecord
  belongs_to :delivery
  belongs_to :shipment
end
