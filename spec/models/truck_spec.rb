require 'rails_helper'

RSpec.describe Truck, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      truck = Truck.new(make: 'Ford', model: 'F-150', year: 2022, mileage: 15000)
      expect(truck).to be_valid
    end

    it 'is invalid without a make' do
      truck = Truck.new(model: 'F-150', year: 2022, mileage: 15000)
      expect(truck).to_not be_valid
      expect(truck.errors[:make]).to include("can't be blank")
    end

    it 'is invalid without a model' do
      truck = Truck.new(make: 'Ford', year: 2022, mileage: 15000)
      expect(truck).to_not be_valid
      expect(truck.errors[:model]).to include("can't be blank")
    end

    it 'is invalid with a year less than 1900' do
      truck = Truck.new(make: 'Ford', model: 'F-150', year: 1899, mileage: 15000)
      expect(truck).to_not be_valid
      expect(truck.errors[:year]).to include("must be greater than or equal to 1900")
    end

    it 'is invalid with a negative mileage' do
      truck = Truck.new(make: 'Ford', model: 'F-150', year: 2022, mileage: -10)
      expect(truck).to_not be_valid
      expect(truck.errors[:mileage]).to include("must be greater than or equal to 0")
    end
  end
end
