class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable

  enum :role, { admin: 0, driver: 1, customer: 2 }

  scope :for_company, ->(company) { where(company_id: company.id) }

  scope :drivers, -> { where(role: "driver") }
  scope :admins, -> { where(role: "admin") }

  belongs_to :company, optional: true

  has_many :shipments, dependent: :nullify
  has_many :deliveries, dependent: :nullify

  # Validations
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :home_address, length: { maximum: 255 }, allow_blank: true
  validates :drivers_license,
    presence: true,
    uniqueness: true,
    length: { is: 8 },
    format: { with: /\A[A-Z0-9]+\z/, message: "only allows uppercase letters and numbers" },
    if: -> { role != "customer" }

  # Instance Methods
  def display_name
    "#{first_name} #{last_name}"
  end

  def admin?
    role == "admin"
  end

  def driver?
    role == "driver"
  end

  def customer?
    role == "customer"
  end

  def has_company?
    company.present?
  end

  # Check if user is available (not on active delivery)
  def available?
    deliveries.active.none?
  end

  # Get the user's active delivery if any
  def active_delivery
    deliveries.active.first
  end
end
