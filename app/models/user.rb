class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable

  enum :role, { driver: 0, admin: 1 }

  scope :drivers, -> { where(role: "driver") }
  scope :admins, -> { where(role: "admin") }

  has_many :shipments, dependent: :nullify

  # Validations
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :drivers_license, presence: true, uniqueness: true, length: { is: 8 }, format: { with: /\A[A-Z0-9]+\z/, message: "only allows uppercase letters and numbers" }

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
end
