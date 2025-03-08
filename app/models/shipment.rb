class Shipment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :company, optional: true
  belongs_to :truck, optional: true
  belongs_to :shipment_status, optional: true

  has_many :delivery_shipments
  has_many :deliveries, through: :delivery_shipments

  validates :name, :sender_name, :sender_address, :receiver_name, :receiver_address, :weight, :length, :width, :height, :boxes, presence: true
  validates :weight, :length, :width, :height, numericality: { greater_than: 0 }
  validates :boxes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :unassigned, -> { where(user_id: nil) }

  scope :for_company, ->(company) { where(company_id: company.id) }

  def status
    shipment_status&.name
  end

  def claimed?
    !company.nil?
  end

  def open?
    !shipment_status&.closed
  end

  def active_delivery
    deliveries.active.first
  end
end
