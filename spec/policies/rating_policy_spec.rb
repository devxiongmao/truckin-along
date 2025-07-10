require 'rails_helper'

RSpec.describe RatingPolicy, type: :policy do
  let(:company) { create(:company) }
  let(:admin) { create(:user, role: 'admin', company: company) }
  let(:driver) { create(:user, role: 'driver', company: company) }
  let(:customer) { create(:user, role: 'customer') }
  let(:rating) { create(:rating, company: company) }

  describe 'permissions' do
    context 'when the user is an admin' do
      let(:user) { admin }
      subject { described_class.new(user, rating) }

      it { expect(subject.create?).to be false }
    end

    context 'when the user is a driver' do
      let(:user) { driver }
      subject { described_class.new(user, rating) }

      it { expect(subject.create?).to be false }
    end

    context 'when the user is a customer' do
      let(:user) { customer }
      subject { described_class.new(user, rating) }

      it { expect(subject.create?).to be true }
    end
  end
end
