require 'rails_helper'

RSpec.describe Offer, type: :model do
  describe 'associations' do
    it { should belong_to(:shipment) }
    it { should belong_to(:company) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(issued: 0, accepted: 1, rejected: 2, withdrawn: 3) }
  end

  describe 'validations' do
    it { should validate_presence_of(:shipment) }
    it { should validate_presence_of(:company) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price) }
  end

  describe 'scopes' do
    describe '.for_company' do
      let(:company1) { create(:company) }
      let(:company2) { create(:company) }
      let!(:offer1) { create(:offer, company: company1) }
      let!(:offer2) { create(:offer, company: company1) }
      let!(:offer3) { create(:offer, company: company2) }

      it 'returns offers for the specified company' do
        expect(Offer.for_company(company1)).to include(offer1, offer2)
        expect(Offer.for_company(company1)).not_to include(offer3)
      end

      it 'returns offers for the other company' do
        expect(Offer.for_company(company2)).to include(offer3)
        expect(Offer.for_company(company2)).not_to include(offer1, offer2)
      end

      it 'returns an empty result when company has no offers' do
        company3 = create(:company)
        expect(Offer.for_company(company3)).to be_empty
      end
    end
  end
end
