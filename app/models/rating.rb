class Rating < ApplicationRecord
  belongs_to :company
  belongs_to :user

  validates :stars, inclusion: { in: 1..5 }

  after_create :increment_company_rating
  after_update :update_company_rating_if_stars_changed
  after_destroy :decrement_company_rating

  private

  def increment_company_rating
    company.with_lock do
      new_count = company.ratings_count + 1
      new_average = ((company.average_rating * company.ratings_count) + stars) / new_count

      company.update!(average_rating: new_average, ratings_count: new_count)
    end
  end

  def update_company_rating_if_stars_changed
    return unless saved_change_to_stars?

    company.with_lock do
      old_stars, new_stars = saved_change_to_stars
      total_stars = (company.average_rating * company.ratings_count)
      new_average = (total_stars - old_stars + new_stars) / company.ratings_count.to_f

      company.update!(average_rating: new_average)
    end
  end

  def decrement_company_rating
    company.with_lock do
      return company.update!(average_rating: 0, ratings_count: 0) if company.ratings_count <= 1

      new_count = company.ratings_count - 1
      new_average = ((company.average_rating * company.ratings_count) - stars) / new_count.to_f

      company.update!(average_rating: new_average, ratings_count: new_count)
    end
  end
end
