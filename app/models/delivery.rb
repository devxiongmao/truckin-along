class Delivery < ApplicationRecord
  belongs_to :user
  belongs_to :truck

  has_many :delivery_shipments
  has_many :shipments, through: :delivery_shipments

  enum :status, {
    scheduled: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }

  validates :status, presence: true

  scope :active, -> { where(status: [ :scheduled, :in_progress ]) }
  scope :inactive, -> { where(status: [ :completed, :cancelled ]) }

  def active?
    scheduled? || in_progress?
  end
end
