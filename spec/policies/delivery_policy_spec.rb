require 'rails_helper'

RSpec.describe DeliveryPolicy, type: :policy do
  let(:company) { create(:company) }
  let(:admin) { create(:user, role: "admin", company: company) }
  let(:driver) { create(:user, role: "driver", company: company) }
  let(:customer) { create(:user, role: "customer") }

  let!(:truck) { create(:truck, company: company) }

  let(:delivery) { create(:delivery, truck: truck) } # Mock delivery object

  describe 'permissions' do
    context 'when the user is an admin' do
      let(:user) { admin }
      subject { described_class.new(user, delivery) }

      it { expect(subject.index?).to be true }
      it { expect(subject.show?).to be true }
      it { expect(subject.close?).to be true }
      it { expect(subject.load_truck?).to be true }
      it { expect(subject.start?).to be true }
    end

    context 'when the user is a driver' do
      let(:user) { driver }
      subject { described_class.new(user, delivery) }

      it { expect(subject.index?).to be true }
      it { expect(subject.show?).to be true }
      it { expect(subject.close?).to be true }
      it { expect(subject.load_truck?).to be true }
      it { expect(subject.start?).to be true }
    end

    context 'when the user is a customer' do
      let(:user) { customer }
      subject { described_class.new(user, delivery) }

      it { expect(subject.index?).to be false }
      it { expect(subject.show?).to be false }
      it { expect(subject.close?).to be false }
      it { expect(subject.load_truck?).to be false }
      it { expect(subject.start?).to be false }
    end
  end
end
