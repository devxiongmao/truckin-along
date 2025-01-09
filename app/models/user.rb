class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable
  
  enum :role, {driver: 0, admin: 1}

  # Convenience methods
  def admin?
    role == "admin"
  end
end
