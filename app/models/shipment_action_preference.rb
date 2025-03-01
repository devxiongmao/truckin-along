class ShipmentActionPreference < ApplicationRecord
  belongs_to :company
  belongs_to :shipment_status, optional: true

  # List of possible actions
  ACTIONS = [
    "claimed_by_company",
    "loaded_onto_truck",
    "out_for_delivery"
  ]

  validates :action, inclusion: { in: ACTIONS }

  # Ensure each company can only have one preference per action
  validates :action, uniqueness: { scope: :company_id }

  scope :for_company, ->(company) { where(company_id: company.id) }
end
