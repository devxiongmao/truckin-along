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
        expect(helper.show_nav_link?(:load_truck)).to be(false)
        expect(helper.show_nav_link?(:start_delivery)).to be(false)
        expect(helper.show_nav_link?(:offers)).to be(false)
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

        it 'returns true for load_truck' do
          expect(helper.show_nav_link?(:load_truck)).to be(true)
        end

        it 'returns true for start_delivery' do
          expect(helper.show_nav_link?(:start_delivery)).to be(true)
        end

        it 'returns true for offers' do
          expect(helper.show_nav_link?(:offers)).to be(true)
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

        it 'returns false for load_truck' do
          expect(helper.show_nav_link?(:load_truck)).to be(false)
        end

        it 'returns false for start_delivery' do
          expect(helper.show_nav_link?(:start_delivery)).to be(false)
        end

        it 'returns true for offers' do
          expect(helper.show_nav_link?(:offers)).to be(true)
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

        it 'returns true for load_truck' do
          expect(helper.show_nav_link?(:load_truck)).to be(true)
        end

        it 'returns true for start_delivery' do
          expect(helper.show_nav_link?(:start_delivery)).to be(true)
        end

        it 'returns true for offers' do
          expect(helper.show_nav_link?(:offers)).to be(true)
        end
      end
    end
  end

  describe '#star_rating' do
    context 'when rating is nil' do
      it 'returns "No ratings yet"' do
        expect(helper.star_rating(nil)).to eq('No ratings yet')
      end
    end

    context 'when rating is 0' do
      it 'returns "No ratings yet"' do
        expect(helper.star_rating(0)).to eq('No ratings yet')
      end
    end

    context 'when rating is a positive integer' do
      it 'displays correct number of full stars for rating 3' do
        result = helper.star_rating(3)
        expect(result).to include('class="star full-star"')
        expect(result).to include('class="star empty-star"')
        expect(result.scan('full-star').count).to eq(3)
        expect(result.scan('empty-star').count).to eq(2)
      end

      it 'displays 5 full stars for rating 5' do
        result = helper.star_rating(5)
        expect(result.scan('full-star').count).to eq(5)
        expect(result.scan('empty-star').count).to eq(0)
        expect(result.scan('half-star').count).to eq(0)
      end

      it 'displays no full stars for rating 0.4' do
        result = helper.star_rating(0.4)
        expect(result.scan('full-star').count).to eq(0)
        expect(result.scan('half-star').count).to eq(0)
        expect(result.scan('empty-star').count).to eq(5)
      end
    end

    context 'when rating has decimal values' do
      it 'displays half star for rating 3.5' do
        result = helper.star_rating(3.5)
        expect(result.scan('full-star').count).to eq(3)
        expect(result.scan('half-star').count).to eq(1)
        expect(result.scan('empty-star').count).to eq(1)
      end

      it 'displays half star for rating 2.7' do
        result = helper.star_rating(2.7)
        expect(result.scan('full-star').count).to eq(2)
        expect(result.scan('half-star').count).to eq(1)
        expect(result.scan('empty-star').count).to eq(2)
      end

      it 'does not display half star for rating 2.4' do
        result = helper.star_rating(2.4)
        expect(result.scan('full-star').count).to eq(2)
        expect(result.scan('half-star').count).to eq(0)
        expect(result.scan('empty-star').count).to eq(3)
      end

      it 'displays half star for rating 4.6' do
        result = helper.star_rating(4.6)
        expect(result.scan('full-star').count).to eq(4)
        expect(result.scan('half-star').count).to eq(1)
        expect(result.scan('empty-star').count).to eq(0)
      end
    end

    context 'when rating exceeds 5' do
      it 'displays 5 full stars for rating 5.5' do
        result = helper.star_rating(5.5)
        expect(result.scan('full-star').count).to eq(5)
        expect(result.scan('half-star').count).to eq(0)
        expect(result.scan('empty-star').count).to eq(0)
      end

      it 'displays 5 full stars for rating 7' do
        result = helper.star_rating(7)
        expect(result.scan('full-star').count).to eq(5)
        expect(result.scan('half-star').count).to eq(0)
        expect(result.scan('empty-star').count).to eq(0)
      end
    end

    context 'when custom size is provided' do
      it 'applies custom font size' do
        result = helper.star_rating(3, size: "2em")
        expect(result).to include('font-size: 2em')
      end

      it 'uses default size when not specified' do
        result = helper.star_rating(3)
        expect(result).to include('font-size: 1em')
      end
    end

    context 'when rating is negative' do
      it 'returns "No ratings yet" for negative rating' do
        expect(helper.star_rating(-1)).to eq('No ratings yet')
      end
    end

    context 'HTML structure' do
      it 'wraps stars in a div with star-rating class' do
        result = helper.star_rating(3)
        expect(result).to include('class="star-rating"')
        expect(result).to start_with('<div')
        expect(result).to end_with('</div>')
      end

      it 'uses correct star symbols' do
        result = helper.star_rating(3.5)
        expect(result).to include('★') # full star
        expect(result).to include('☆') # empty/half star
      end

      it 'has proper HTML escaping' do
        result = helper.star_rating(3)
        expect(result).to be_html_safe
      end
    end
  end
end
