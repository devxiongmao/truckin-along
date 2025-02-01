class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable

  enum :role, { driver: 0, admin: 1, customer: 2 }

  scope :for_company, ->(company) { where(company_id: company.id) }

  scope :drivers, -> { where(role: "driver") }
  scope :admins, -> { where(role: "admin") }

  belongs_to :company, optional: true

  has_many :shipments, dependent: :nullify

  # Validations
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }

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
end
