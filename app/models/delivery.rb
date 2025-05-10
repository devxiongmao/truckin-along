class Delivery < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :truck

  has_many :delivery_shipments, dependent: :nullify
  has_many :shipments, through: :delivery_shipments

  has_many :forms, as: :formable

  enum :status, {
    scheduled: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }

  validates :status, presence: true

  scope :active, -> { where(status: [:scheduled, :in_progress]) }
  scope :inactive, -> { where(status: [ :completed, :cancelled ]) }
  scope :for_user, ->(user) { where(user_id: user.id) }


  def active?
    scheduled? || in_progress?
  end

  def can_be_closed?
    delivery_shipments.all? { |del_ship| !del_ship.delivered_date.nil? } && active?
  end

  def volume
    shipments.reduce(0.0) { |curr_volume, shipment| curr_volume + shipment.volume }
  end

  def weight
    shipments.reduce(0.0) { |curr_weight, shipment| curr_weight + shipment.weight }
  end

  def open_shipments
    shipments
      .joins(:delivery_shipments)
      .where(delivery_shipments: { delivery_id: id, delivered_date: nil })
  end

  def delivered_shipments
    shipments
      .joins(:delivery_shipments)
      .where.not(delivery_shipments: { delivered_date: nil })
      .where(delivery_shipments: { delivery_id: id })
  end
end
