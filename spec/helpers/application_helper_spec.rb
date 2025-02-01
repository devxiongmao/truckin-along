require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:admin_user) { create(:user, :admin) }
  let(:customer_user) { create(:user, :customer) }
  let(:driver_user) { create(:user, :driver) }

  describe '#show_nav_link?' do
    context 'when user is not signed in' do
      it 'returns false for any link' do
        allow(helper).to receive(:user_signed_in?).and_return(false)
        expect(helper.show_nav_link?(:admin)).to be(false)
        expect(helper.show_nav_link?(:shipments)).to be(false)
        expect(helper.show_nav_link?(:deliveries)).to be(false)
        expect(helper.show_nav_link?(:truck_loading)).to be(false)
      end
    end

    context 'when user is signed in' do
      before do
        allow(helper).to receive(:user_signed_in?).and_return(true)
      end

      context 'when the user is an admin' do
        before { allow(helper).to receive(:current_user).and_return(admin_user) }

        it 'returns true for admin' do
          expect(helper.show_nav_link?(:admin)).to be(true)
        end

        it 'returns false for shipments' do
          expect(helper.show_nav_link?(:shipments)).to be(false)
        end

        it 'returns true for deliveries' do
          expect(helper.show_nav_link?(:deliveries)).to be(true)
        end

        it 'returns true for truck_loading' do
          expect(helper.show_nav_link?(:truck_loading)).to be(true)
        end
      end

      context 'when the user is a customer' do
        before { allow(helper).to receive(:current_user).and_return(customer_user) }

        it 'returns false for admin' do
          expect(helper.show_nav_link?(:admin)).to be(false)
        end

        it 'returns true for shipments' do
          expect(helper.show_nav_link?(:shipments)).to be(true)
        end

        it 'returns false for deliveries' do
          expect(helper.show_nav_link?(:deliveries)).to be(false)
        end

        it 'returns false for truck_loading' do
          expect(helper.show_nav_link?(:truck_loading)).to be(false)
        end
      end

      context 'when the user is a driver' do
        before { allow(helper).to receive(:current_user).and_return(driver_user) }

        it 'returns false for admin' do
          expect(helper.show_nav_link?(:admin)).to be(false)
        end

        it 'returns false for shipments' do
          expect(helper.show_nav_link?(:shipments)).to be(false)
        end

        it 'returns true for deliveries' do
          expect(helper.show_nav_link?(:deliveries)).to be(true)
        end

        it 'returns true for truck_loading' do
          expect(helper.show_nav_link?(:truck_loading)).to be(true)
        end
      end
    end
  end
end
