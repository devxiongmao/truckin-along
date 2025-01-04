class Truck < ApplicationRecord
    has_many :shipments

    validates :make, :model, presence: true
    validates :year, numericality: { only_integer: true, greater_than_or_equal_to: 1900 }
    validates :mileage, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
