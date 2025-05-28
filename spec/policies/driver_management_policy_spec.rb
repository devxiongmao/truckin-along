require 'rails_helper'

RSpec.describe DriverManagementPolicy, type: :policy do
  let(:admin) { User.new(role: 'admin') }
  let(:driver) { User.new(role: 'driver') }
  let(:customer) { User.new(role: 'customer') }

  describe 'permissions' do
    context 'when the user is an admin' do
      let(:user) { admin }
      subject { described_class.new(user, nil) }

      it { expect(subject.new?).to be true }
      it { expect(subject.create?).to be true }
      it { expect(subject.edit?).to be true }
      it { expect(subject.update?).to be true }
      it { expect(subject.reset_password?).to be true }
    end

    context 'when the user is a driver' do
      let(:user) { driver }
      subject { described_class.new(user, nil) }

      it { expect(subject.new?).to be false }
      it { expect(subject.create?).to be false }
      it { expect(subject.edit?).to be false }
      it { expect(subject.update?).to be false }
      it { expect(subject.reset_password?).to be false }
    end

    context 'when the user is a customer' do
      let(:user) { customer }
      subject { described_class.new(user, nil) }

      it { expect(subject.new?).to be false }
      it { expect(subject.create?).to be false }
      it { expect(subject.edit?).to be false }
      it { expect(subject.update?).to be false }
      it { expect(subject.reset_password?).to be false }
    end
  end
end
