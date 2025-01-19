class Truck < ApplicationRecord
  belongs_to :company

  has_many :shipments

  validates :make, :model, presence: true
  validates :year, numericality: { only_integer: true, greater_than_or_equal_to: 1900 }
  validates :mileage, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :for_company, ->(company) { where(company_id: company.id) }

  def display_name
    "#{make}-#{model}-#{year}"
  end
end
