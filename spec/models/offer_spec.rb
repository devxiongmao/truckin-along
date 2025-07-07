require 'rails_helper'

RSpec.describe Offer, type: :model do
  let(:company) { create(:company) }
  let(:shipment) { create(:shipment) }

  describe 'validations' do
    it { should validate_presence_of(:shipment) }
    it { should validate_presence_of(:company) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price) }
  end

  describe 'associations' do
    it { should belong_to(:shipment) }
    it { should belong_to(:company) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(issued: 0, accepted: 1, rejected: 2, withdrawn: 3) }
  end

  describe 'scopes' do
    describe '.for_company' do
      let!(:offer1) { create(:offer, company: company) }
      let!(:offer2) { create(:offer, company: company) }
      let!(:other_company_offer) { create(:offer) }

      it 'returns offers for the specified company' do
        expect(Offer.for_company(company)).to include(offer1, offer2)
        expect(Offer.for_company(company)).not_to include(other_company_offer)
      end
    end
  end

  describe 'validation: only_one_active_offer_per_company_per_shipment' do
    let!(:existing_offer) { create(:offer, shipment: shipment, company: company, status: :issued) }

    context 'when creating a new offer for the same shipment and company' do
      it 'is invalid for issued status' do
        new_offer = build(:offer, shipment: shipment, company: company, status: :issued)
        expect(new_offer).not_to be_valid
        expect(new_offer.errors[:base]).to include("You already have an active offer for this shipment")
      end

      it 'is valid for accepted status' do
        new_offer = build(:offer, shipment: shipment, company: company, status: :accepted)
        expect(new_offer).to be_valid
      end

      it 'is valid for rejected status' do
        new_offer = build(:offer, shipment: shipment, company: company, status: :rejected)
        expect(new_offer).to be_valid
      end

      it 'is valid for withdrawn status' do
        new_offer = build(:offer, shipment: shipment, company: company, status: :withdrawn)
        expect(new_offer).to be_valid
      end
    end

    context 'when creating a new offer for different shipment' do
      let(:different_shipment) { create(:shipment) }
      let(:new_offer) { build(:offer, shipment: different_shipment, company: company, status: :issued) }

      it 'is valid' do
        expect(new_offer).to be_valid
      end
    end

    context 'when creating a new offer for different company' do
      let(:different_company) { create(:company) }
      let(:new_offer) { build(:offer, shipment: shipment, company: different_company, status: :issued) }

      it 'is valid' do
        expect(new_offer).to be_valid
      end
    end

    context 'when existing offer is not issued' do
      before { existing_offer.update!(status: :rejected) }

      let(:new_offer) { build(:offer, shipment: shipment, company: company, status: :issued) }

      it 'is valid' do
        expect(new_offer).to be_valid
      end
    end
  end
end
