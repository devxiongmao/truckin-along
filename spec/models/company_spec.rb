require 'rails_helper'

RSpec.describe Company, type: :model do
  subject { build(:company) }

  # Associations
  it { should have_many(:shipments).dependent(:nullify) }
  it { should have_many(:users).dependent(:destroy) }
  it { should have_many(:shipment_statuses).dependent(:destroy) }
  it { should have_many(:trucks).dependent(:destroy) }
  it { should have_many(:shipment_action_preferences).dependent(:destroy) }
  it { should have_many(:forms).dependent(:destroy) }

  # Validations
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:address) }

  describe 'phone_number format' do
    it 'is valid with correct format' do
      valid_numbers = [
        '+1234567890',
        '123-456-7890',
        '(123) 456-7890',
        '+1 (123) 456-7890',
        '123 456 7890',
        '+44 7911 123456'
      ]

      valid_numbers.each do |number|
        subject.phone_number = number
        expect(subject).to be_valid, "expected #{number.inspect} to be valid"
      end
    end

    it 'is valid when blank' do
      subject.phone_number = nil
      expect(subject).to be_valid
    end

    it 'is invalid with incorrect format' do
      invalid_numbers = [
        'abc1234567',
        '123-abc-7890',
        '123456',
        '+1(123)456-7890ext',
        '++1234567890',
        '123_456_7890'
      ]

      invalid_numbers.each do |number|
        subject.phone_number = number
        expect(subject).not_to be_valid, "expected #{number.inspect} to be invalid"
      end
    end
  end
end
