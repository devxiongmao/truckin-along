class ShipmentStatus < ApplicationRecord
  belongs_to :company

  has_many :shipments, dependent: :nullify
  has_many :shipment_action_preferences, dependent: :nullify

  validates :name, presence: true
  validates :name, length: { maximum: 255 }

  scope :for_company, ->(company) { where(company_id: company.id) }
end
