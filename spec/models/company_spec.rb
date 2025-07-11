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
  it { should have_many(:ratings).dependent(:destroy) }

  # Validations
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:address) }
  it { should validate_numericality_of(:average_rating).is_greater_than_or_equal_to(0) }

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

  describe '#admin_emails' do
    let(:company) { create(:company) }

    let!(:admin1) { create(:user, company: company, role: 'admin', email: 'admin1@example.com') }
    let!(:admin2) { create(:user, company: company, role: 'admin', email: 'admin2@example.com') }
    let!(:user)    { create(:user, company: company, role: 'driver', email: 'user@example.com') }

    it 'returns only the emails of admin users' do
      expect(company.admin_emails).to match_array([ 'admin1@example.com', 'admin2@example.com' ])
    end

    it 'does not include non-admin emails' do
      expect(company.admin_emails).not_to include('user@example.com')
    end
  end

  describe 'rating attributes' do
    let(:company) { create(:company) }

    it 'has default values for rating attributes' do
      expect(company.average_rating).to eq(0.0)
      expect(company.ratings_count).to eq(0)
    end

    it 'can have ratings associated with it' do
      customer = create(:user, :customer, company: company)
      rating = create(:rating, company: company, user: customer, stars: 5)

      expect(company.ratings).to include(rating)
    end
  end
end
