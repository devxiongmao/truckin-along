class ShipmentStatus < ApplicationRecord
  has_many :shipments, dependent: :destroy

  validates :name, presence: true
  validates :name, length: { maximum: 255 }
end
