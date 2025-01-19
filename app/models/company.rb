class Company < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :shipments
  has_many :shipment_statuses
  has_many :trucks

  validates :name, presence: true, uniqueness: true
  validates :address, presence: true
end
