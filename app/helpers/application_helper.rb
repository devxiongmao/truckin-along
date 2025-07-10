module ApplicationHelper
  def show_nav_link?(link)
    return false unless user_signed_in?

    case link
    when :admin
      current_user.admin?
    when :shipments
      current_user.customer?
    when :deliveries, :load_truck, :start_delivery
      current_user.admin? || current_user.driver?
    when :offers
      true
    else
      false
    end
  end

  def star_rating(rating, size: "1em")
    return "No ratings yet" if rating.nil? || rating <= 0

    # Cap the rating at 5
    capped_rating = [ rating, 5 ].min

    full_stars = capped_rating.floor
    has_half_star = (capped_rating - full_stars) >= 0.5

    stars_html = ""

    # Full stars
    full_stars.times do
      stars_html += '<span class="star full-star">★</span>'
    end

    # Half star if needed
    if has_half_star
      stars_html += '<span class="star half-star">☆</span>'
    end

    # Empty stars to complete 5 stars
    empty_stars = 5 - full_stars - (has_half_star ? 1 : 0)
    empty_stars.times do
      stars_html += '<span class="star empty-star">☆</span>'
    end

    content_tag(:div, stars_html.html_safe, class: "star-rating", style: "font-size: #{size};")
  end
end
