require 'rails_helper'

RSpec.describe Company, type: :model do
  it { should have_many(:users).dependent(:nullify) }
  it { should have_many(:shipments) }
  it { should have_many(:shipment_statuses) }
  it { should have_many(:trucks) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:address) }
  it { should validate_uniqueness_of(:name) }
end
