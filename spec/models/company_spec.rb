require 'rails_helper'

RSpec.describe Company, type: :model do
  it { should have_many(:shipments).dependent(:nullify) }

  it { should have_many(:users).dependent(:destroy) }
  it { should have_many(:shipment_statuses).dependent(:destroy) }
  it { should have_many(:trucks).dependent(:destroy) }
  it { should have_many(:shipment_action_preferences).dependent(:destroy) }


  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:address) }
  it { should validate_uniqueness_of(:name) }
end
