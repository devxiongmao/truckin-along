require 'rails_helper'

RSpec.describe Offer, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:company) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(issued: 0, accepted: 1, rejected: 2) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:company) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price) }
  end
end 