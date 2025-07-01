class Offer < ApplicationRecord
  belongs_to :user
  belongs_to :company

  enum status: { issued: 0, accepted: 1, rejected: 2 }

  validates :user, presence: true
  validates :company, presence: true
  validates :status, presence: true
  validates :price, presence: true, numericality: true

end 