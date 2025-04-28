class Shipment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :company, optional: true
  belongs_to :truck, optional: true
  belongs_to :shipment_status, optional: true

  has_many :delivery_shipments, dependent: :nullify
  has_many :deliveries, through: :delivery_shipments

  validates :name, :sender_name, :sender_address, :receiver_name, :receiver_address, :weight, :length, :width, :height, presence: true
  validates :weight, :length, :width, :height, numericality: { greater_than: 0 }

  after_validation :geocode_sender, if: ->(obj) { obj.sender_address.present? && obj.sender_address_changed? }
  after_validation :geocode_receiver, if: ->(obj) { obj.receiver_address.present? && obj.receiver_address_changed? }

  scope :for_user, ->(user) { where(user_id: user.id) }

  scope :for_company, ->(company) { where(company_id: company.id) }

  def status
    shipment_status&.name
  end

  def claimed?
    !company.nil?
  end

  def open?
    !shipment_status&.closed
  end

  def active_delivery
    deliveries.active.first
  end

  def volume
    length * width * height
  end

  private

  def geocode_sender
    result = Geocoder.search(sender_address).first
    if result
      self.sender_latitude = result.latitude
      self.sender_longitude = result.longitude
    end
  end

  def geocode_receiver
    result = Geocoder.search(receiver_address).first
    if result
      self.receiver_latitude = result.latitude
      self.receiver_longitude = result.longitude
    end
  end
end
