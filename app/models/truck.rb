class Truck < ApplicationRecord
  belongs_to :company

  has_many :shipments, dependent: :nullify
  has_many :deliveries, dependent: :destroy

  validates :make, :model, :weight, :length, :width, :height, presence: true
  validates :weight, :length, :width, :height, numericality: { greater_than: 0 }
  validates :year, numericality: { only_integer: true, greater_than_or_equal_to: 1900 }
  validates :mileage, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :vin, presence: true, uniqueness: true, length: { is: 17 }
  validates :license_plate, presence: true

  scope :for_company, ->(company) { where(company_id: company.id) }

  def display_name
    "#{make}-#{model}-#{year}(#{license_plate})"
  end

  # Check if truck is available
  def available?
    deliveries.active.none?
  end

  # Get the truck's active delivery if any
  def active_delivery
    deliveries.active.first
  end
end
