class Offer < ApplicationRecord
  belongs_to :shipment
  belongs_to :company

  enum :status, { issued: 0, accepted: 1, rejected: 2, withdrawn: 3 }

  validates :shipment, presence: true
  validates :company, presence: true
  validates :status, presence: true
  validates :price, presence: true, numericality: true

  scope :for_company, ->(company) { where(company_id: company.id) }
end
