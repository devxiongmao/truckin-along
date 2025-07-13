class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.customer?
      @shipments = Shipment.for_user(current_user).includes(:company).order(deliver_by: :asc)

      @total_shipments = @shipments.size
      @pending_shipments = @shipments.count { |s| s.company_id.nil? }
      @claimed_shipments = @total_shipments - @pending_shipments
      @due_this_week_shipments = @shipments.count { |s| s.deliver_by.present? && s.deliver_by <= 7.days.from_now }

      @status_counts = @shipments.group_by(&:status).transform_values(&:size)

      @recent_shipments = @shipments.first(5)

      @upcoming_shipments = @shipments
                              .select { |s| s.deliver_by.present? && s.deliver_by <= 14.days.from_now }
                              .sort_by(&:deliver_by)
                              .first(5)

      @pending_offers = Offer.joins(:shipment)
                             .where(shipments: { user_id: current_user.id }, status: :issued)

    else
      @deliveries = Delivery.for_user(current_user).includes(:truck, :shipments)

      @total_deliveries = @deliveries.size
      @active_deliveries = @deliveries.active.size
      @scheduled_deliveries = @deliveries.scheduled.size
      @completed_deliveries = @deliveries.completed.size
      @recent_deliveries = @deliveries.order(created_at: :desc).first(5)

      @trucks = Truck.for_company(current_company).includes(:deliveries, :shipments)

      @total_trucks = @trucks.size
      @trucks_needing_maintenance = @trucks.count { |t| !t.active }
      @active_trucks = @trucks.count { |t| t.active }
      @available_trucks = @trucks.count { |t| t.available? }
      @fleet_overview_trucks = @trucks.first(5)

      @active_delivery = current_user.active_delivery
    end
  end
end
