require 'rails_helper'

RSpec.describe OfferPolicy, type: :policy do
  let(:admin) { User.new(role: 'admin') }
  let(:driver) { User.new(role: 'driver') }
  let(:customer) { User.new(role: 'customer') }
  let(:offer) { Offer.new }

  describe 'permissions' do
    context 'when the user is an admin' do
      let(:user) { admin }
      subject { described_class.new(user, offer) }

      it { expect(subject.index?).to be true }
      it { expect(subject.create?).to be true }
    end

    context 'when the user is a driver' do
      let(:user) { driver }
      subject { described_class.new(user, offer) }

      it { expect(subject.index?).to be true }
      it { expect(subject.create?).to be true }
    end

    context 'when the user is a customer' do
      let(:user) { customer }
      subject { described_class.new(user, offer) }

      it { expect(subject.index?).to be true }
      it { expect(subject.create?).to be false }
    end
  end
end 