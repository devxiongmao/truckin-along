class Shipment < ApplicationRecord
  belongs_to :truck, optional: true

  validates :name, :status, :sender_name, :sender_address, :receiver_name, :receiver_address, :weight, :boxes, presence: true
  validates :weight, numericality: { greater_than: 0 }
  validates :boxes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
