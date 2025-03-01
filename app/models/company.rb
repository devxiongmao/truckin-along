class Company < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :shipments
  has_many :shipment_statuses
  has_many :trucks
  has_many :shipment_action_preferences

  validates :name, presence: true, uniqueness: true
  validates :address, presence: true
end
