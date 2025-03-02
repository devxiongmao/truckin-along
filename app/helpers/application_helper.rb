module ApplicationHelper
  def show_nav_link?(link)
    return false unless user_signed_in?

    case link
    when :admin
      current_user.admin?
    when :shipments
      current_user.customer?
    when :deliveries, :truck_loading, :start_delivery
      current_user.admin? || current_user.driver?
    else
      false
    end
  end
end
