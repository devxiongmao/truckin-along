require 'rails_helper'

RSpec.describe CompanyPolicy, type: :policy do
  let(:admin_without_company) { User.new(role: 'admin', company: nil) }
  let(:admin_with_company) { User.new(role: 'admin', company: Company.new) }
  let(:driver) { User.new(role: 'driver') }
  let(:customer) { User.new(role: 'customer') }

  let(:company) { Company.new }

  describe 'permissions' do
    context 'when the user is an admin without a company' do
      let(:user) { admin_without_company }
      subject { described_class.new(user, company) }

      it { expect(subject.new?).to be true }
      it { expect(subject.create?).to be true }
      it { expect(subject.edit?).to be true }
      it { expect(subject.update?).to be true }
      it { expect(subject.show?).to be true }
    end

    context 'when the user is an admin with a company' do
      let(:user) { admin_with_company }
      subject { described_class.new(user, company) }

      it { expect(subject.new?).to be false }
      it { expect(subject.create?).to be false }
      it { expect(subject.edit?).to be true }
      it { expect(subject.update?).to be true }
      it { expect(subject.show?).to be true }
    end

    context 'when the user is a driver' do
      let(:user) { driver }
      subject { described_class.new(user, company) }

      it { expect(subject.new?).to be false }
      it { expect(subject.create?).to be false }
      it { expect(subject.edit?).to be false }
      it { expect(subject.update?).to be false }
      it { expect(subject.show?).to be true }

    end

    context 'when the user is a customer' do
      let(:user) { customer }
      subject { described_class.new(user, company) }

      it { expect(subject.new?).to be false }
      it { expect(subject.create?).to be false }
      it { expect(subject.edit?).to be false }
      it { expect(subject.update?).to be false }
      it { expect(subject.show?).to be true }
    end
  end
end
