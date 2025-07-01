require 'rails_helper'

RSpec.describe TruckPolicy, type: :policy do
  let(:admin) { User.new(role: 'admin') }
  let(:driver) { User.new(role: 'driver') }
  let(:customer) { User.new(role: 'customer') }

  let(:truck) { Truck.new } # Mock shipment object

  describe 'permissions' do
    context 'when the user is an admin' do
      let(:user) { admin }
      subject { described_class.new(user, truck) }

      it { expect(subject.show?).to be true }
      it { expect(subject.new?).to be true }
      it { expect(subject.edit?).to be true }
      it { expect(subject.create?).to be true }
      it { expect(subject.update?).to be true }
      it { expect(subject.destroy?).to be true }
      it { expect(subject.create_form?).to be true }
    end

    context 'when the user is a driver' do
      let(:user) { driver }
      subject { described_class.new(user, truck) }

      it { expect(subject.show?).to be true }
      it { expect(subject.new?).to be false }
      it { expect(subject.edit?).to be false }
      it { expect(subject.create?).to be false }
      it { expect(subject.update?).to be false }
      it { expect(subject.destroy?).to be false }
      it { expect(subject.create_form?).to be true }
    end

    context 'when the user is a customer' do
      let(:user) { customer }
      subject { described_class.new(user, truck) }

      it { expect(subject.show?).to be false }
      it { expect(subject.new?).to be false }
      it { expect(subject.edit?).to be false }
      it { expect(subject.create?).to be false }
      it { expect(subject.update?).to be false }
      it { expect(subject.destroy?).to be false }
      it { expect(subject.create_form?).to be false }
    end
  end
end
