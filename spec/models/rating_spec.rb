require 'rails_helper'

RSpec.describe Rating, type: :model do
  subject { build(:rating) }

  describe 'associations' do
    it { should belong_to(:company) }
    it { should belong_to(:user) }
    it { should belong_to(:delivery_shipment) }
  end

  describe 'validations' do
    it { should validate_inclusion_of(:stars).in_range(1..5) }
    it { should validate_uniqueness_of(:delivery_shipment_id)}
  end

  describe 'callbacks' do
    let(:company) { create(:company) }
    let(:user) { create(:user, :customer, company: company) }

    describe '#increment_company_rating' do
      context 'when creating a new rating' do
        it 'increments the company ratings count' do
          expect {
            create(:rating, company: company, user: user, stars: 4)
          }.to change { company.reload.ratings_count }.by(1)
        end

        it 'updates the company average rating' do
          expect {
            create(:rating, company: company, user: user, stars: 4)
          }.to change { company.reload.average_rating }.from(0.0).to(4.0)
        end

        it 'calculates average correctly with multiple ratings' do
          create(:rating, company: company, user: user, stars: 4)
          create(:rating, company: company, user: create(:user, :customer, company: company), stars: 5)

          company.reload
          expect(company.average_rating).to eq(4.5)
          expect(company.ratings_count).to eq(2)
        end

        it 'handles decimal averages correctly' do
          create(:rating, company: company, user: user, stars: 3)
          create(:rating, company: company, user: create(:user, :customer, company: company), stars: 4)

          company.reload
          expect(company.average_rating).to eq(3.5)
        end
      end
    end

    describe '#update_company_rating_if_stars_changed' do
      let!(:rating) { create(:rating, company: company, user: user, stars: 3) }

      context 'when stars are changed' do
        it 'updates the company average rating' do
          expect {
            rating.update!(stars: 5)
          }.to change { company.reload.average_rating }.from(3.0).to(5.0)
        end

        it 'does not change the ratings count' do
          expect {
            rating.update!(stars: 5)
          }.not_to change { company.reload.ratings_count }
        end

        it 'calculates new average correctly with multiple ratings' do
          create(:rating, company: company, user: create(:user, :customer, company: company), stars: 4)

          # Initial average: (3 + 4) / 2 = 3.5
          expect(company.reload.average_rating).to eq(3.5)

          # Change first rating from 3 to 5: (5 + 4) / 2 = 4.5
          rating.update!(stars: 5)
          expect(company.reload.average_rating).to eq(4.5)
        end
      end

      context 'when stars are not changed' do
        it 'does not update the company average rating' do
          expect {
            rating.update!(comment: 'Updated comment')
          }.not_to change { company.reload.average_rating }
        end
      end

      context 'when other attributes are changed' do
        it 'does not trigger rating recalculation' do
          expect {
            rating.update!(comment: 'New comment')
          }.not_to change { company.reload.average_rating }
        end
      end
    end

    describe '#decrement_company_rating' do
      let!(:rating) { create(:rating, company: company, user: user, stars: 4) }

      context 'when destroying a rating' do
        it 'decrements the company ratings count' do
          expect {
            rating.destroy!
          }.to change { company.reload.ratings_count }.by(-1)
        end

        it 'updates the company average rating' do
          expect {
            rating.destroy!
          }.to change { company.reload.average_rating }.from(4.0).to(0.0)
        end

        context 'when it is the only rating' do
          it 'resets average to 0 and count to 0' do
            rating.destroy!
            company.reload

            expect(company.average_rating).to eq(0.0)
            expect(company.ratings_count).to eq(0)
          end
        end

        context 'when there are multiple ratings' do
          let!(:second_rating) { create(:rating, company: company, user: create(:user, :customer, company: company), stars: 5) }

          it 'recalculates average correctly' do
            # Initial: (4 + 5) / 2 = 4.5
            expect(company.reload.average_rating).to eq(4.5)

            # After destroying first rating: 5 / 1 = 5.0
            rating.destroy!
            expect(company.reload.average_rating).to eq(5.0)
            expect(company.ratings_count).to eq(1)
          end
        end
      end
    end
  end

  describe 'concurrency handling' do
    let(:company) { create(:company) }
    let(:user1) { create(:user, :customer, company: company) }
    let(:user2) { create(:user, :customer, company: company) }

    it 'handles concurrent rating creation correctly' do
      # Simulate concurrent rating creation
      threads = []
      results = []

      5.times do |i|
        threads << Thread.new do
          user = i.even? ? user1 : user2
          rating = create(:rating, company: company, user: user, stars: rand(1..5))
          results << rating
        end
      end

      threads.each(&:join)
      company.reload

      expect(company.ratings_count).to eq(5)
      expect(company.ratings.count).to eq(5)
    end
  end

  describe 'edge cases' do
    let(:company) { create(:company) }
    let(:user) { create(:user, :customer, company: company) }

    context 'when company has no ratings' do
      it 'handles first rating creation correctly' do
        rating = create(:rating, company: company, user: user, stars: 3)
        company.reload

        expect(company.average_rating).to eq(3.0)
        expect(company.ratings_count).to eq(1)
      end
    end

    context 'when updating rating multiple times' do
      let!(:rating) { create(:rating, company: company, user: user, stars: 3) }

      it 'maintains correct average through multiple updates' do
        # First update: 3 -> 4
        rating.update!(stars: 4)
        expect(company.reload.average_rating).to eq(4.0)

        # Second update: 4 -> 5
        rating.update!(stars: 5)
        expect(company.reload.average_rating).to eq(5.0)

        # Third update: 5 -> 2
        rating.update!(stars: 2)
        expect(company.reload.average_rating).to eq(2.0)
      end
    end

    context 'when destroying and recreating ratings' do
      let!(:rating) { create(:rating, company: company, user: user, stars: 4) }

      it 'maintains correct state' do
        expect(company.reload.average_rating).to eq(4.0)
        expect(company.ratings_count).to eq(1)

        rating.destroy!
        expect(company.reload.average_rating).to eq(0.0)
        expect(company.ratings_count).to eq(0)

        create(:rating, company: company, user: user, stars: 5)
        expect(company.reload.average_rating).to eq(5.0)
        expect(company.ratings_count).to eq(1)
      end
    end
  end
end
