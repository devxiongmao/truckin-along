require 'rails_helper'

RSpec.describe ShipmentPolicy, type: :policy do
  let(:admin) { User.new(role: 'admin') }
  let(:driver) { User.new(role: 'driver') }
  let(:customer) { User.new(role: 'customer') }
  
  # User from a company for testing company-specific permissions
  let(:company_user) { 
    user = User.new(role: 'driver')
    user.company_id = 1
    user
  }
  
  let(:company_shipment) { 
    shipment = Shipment.new
    shipment.company_id = 1
    shipment
  }
  
  let(:other_company_shipment) { 
    shipment = Shipment.new
    shipment.company_id = 2
    shipment
  }
  
  let(:shipment) { Shipment.new } # Mock shipment object

  describe 'permissions' do
    context 'when the user is an admin' do
      let(:user) { admin }
      subject { described_class.new(user, shipment) }

      it { expect(subject.index?).to be false }
      it { expect(subject.show?).to be true }
      it { expect(subject.new?).to be false }
      it { expect(subject.edit?).to be true }
      it { expect(subject.create?).to be false }
      it { expect(subject.update?).to be true }
      it { expect(subject.destroy?).to be false }
      it { expect(subject.copy?).to be false }
      it { expect(subject.close?).to be true }
      it { expect(subject.assign?).to be true }
      it { expect(subject.assign_shipments_to_truck?).to be true }
      it { expect(subject.initiate_delivery?).to be true }
    end

    context 'when the user is a driver' do
      let(:user) { driver }
      subject { described_class.new(user, shipment) }

      it { expect(subject.index?).to be false }
      it { expect(subject.show?).to be true }
      it { expect(subject.new?).to be false }
      it { expect(subject.edit?).to be true }
      it { expect(subject.create?).to be false }
      it { expect(subject.update?).to be true }
      it { expect(subject.destroy?).to be false }
      it { expect(subject.copy?).to be false }
      it { expect(subject.close?).to be true }
      it { expect(subject.assign?).to be true }
      it { expect(subject.assign_shipments_to_truck?).to be true }
      it { expect(subject.initiate_delivery?).to be true }
    end

    context 'when the user is a customer' do
      let(:user) { customer }
      subject { described_class.new(user, shipment) }

      it { expect(subject.index?).to be true }
      it { expect(subject.show?).to be true }
      it { expect(subject.new?).to be true }
      it { expect(subject.edit?).to be true }
      it { expect(subject.create?).to be true }
      it { expect(subject.update?).to be true }
      it { expect(subject.destroy?).to be true }
      it { expect(subject.copy?).to be true }
      it { expect(subject.close?).to be false }
      it { expect(subject.assign?).to be false }
      it { expect(subject.assign_shipments_to_truck?).to be false }
      it { expect(subject.initiate_delivery?).to be false }
    end
    
    context 'when the user belongs to the same company as the shipment' do
      let(:user) { company_user }
      
      context 'with shipment from same company' do
        subject { described_class.new(user, company_shipment) }
        
        it { expect(subject.index?).to be false }
        it { expect(subject.show?).to be true }
        it { expect(subject.new?).to be false }
        it { expect(subject.edit?).to be true }
        it { expect(subject.create?).to be false }
        it { expect(subject.update?).to be true }
        it { expect(subject.destroy?).to be false }
        it { expect(subject.copy?).to be false }
        it { expect(subject.close?).to be true }
        it { expect(subject.assign?).to be true }
        it { expect(subject.assign_shipments_to_truck?).to be true }
        it { expect(subject.initiate_delivery?).to be true }
      end
      
      context 'with shipment from different company' do
        subject { described_class.new(user, other_company_shipment) }
        
        it { expect(subject.edit?).to be false }
        it { expect(subject.update?).to be false }
      end
    end
  end
end