require 'rails_helper'

RSpec.describe Company, type: :model do
  it { should have_many(:users).dependent(:nullify) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:address) }
  it { should validate_uniqueness_of(:name) }
end
