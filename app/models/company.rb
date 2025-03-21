class Company < ApplicationRecord
  has_many :shipments, dependent: :nullify

  has_many :users, dependent: :destroy
  has_many :shipment_statuses, dependent: :destroy
  has_many :trucks, dependent: :destroy
  has_many :shipment_action_preferences, dependent: :destroy
  has_many :forms, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :address, presence: true
end
