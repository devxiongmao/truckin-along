class Company < ApplicationRecord
  has_many :shipments, dependent: :nullify

  has_many :users, dependent: :destroy
  has_many :shipment_statuses, dependent: :destroy
  has_many :trucks, dependent: :destroy
  has_many :shipment_action_preferences, dependent: :destroy
  has_many :forms, dependent: :destroy
  has_many :ratings, dependent: :destroy

  validates :average_rating, numericality: { greater_than_or_equal_to: 0 }

  validates :name, presence: true, uniqueness: true
  validates :address, presence: true

  validates :phone_number,
          allow_blank: true,
          format: {
            with: /\A\+?[\d\s\-()]{10,20}\z/,
            message: "must be a valid phone number (can include +, -, space, parentheses)"
          }

  def admin_emails
    users.admins.pluck(:email)
  end
end
