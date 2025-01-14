class Shipment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :truck, optional: true
  belongs_to :shipment_status

  validates :name, :sender_name, :sender_address, :receiver_name, :receiver_address, :weight, :boxes, presence: true
  validates :weight, numericality: { greater_than: 0 }
  validates :boxes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :unassigned, -> { where(user_id: nil) }

  def status
    shipment_status&.name
  end
end
