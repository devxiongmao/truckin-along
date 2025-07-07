class Offer < ApplicationRecord
  belongs_to :shipment
  belongs_to :company

  enum :status, { issued: 0, accepted: 1, rejected: 2, withdrawn: 3 }

  validates :shipment, presence: true
  validates :company, presence: true
  validates :status, presence: true
  validates :price, presence: true, numericality: true
  validate :only_one_active_offer_per_company_per_shipment, on: :create

  scope :for_company, ->(company) { where(company_id: company.id) }

  private

  def only_one_active_offer_per_company_per_shipment
    # Guard clause needed for tests.
    # Reminder: Statuses for offers are ALWAYS controller via requests
    # bulk_create action sets to issued, accept action sets to accept, withdraw action sets to withdraw, etc
    return unless status == "issued"

    existing_offer = Offer.where(
      shipment: shipment,
      company: company,
      status: :issued
    ).first

    if existing_offer
      errors.add(:base, "You already have an active offer for this shipment")
    end
  end
end
