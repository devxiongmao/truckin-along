class ShipmentStatus < ApplicationRecord
  belongs_to :company

  has_many :shipments, dependent: :destroy

  validates :name, presence: true
  validates :name, length: { maximum: 255 }

  scope :for_company, ->(company) { where(company_id: company.id) }
end
