class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.customer?
      @shipments = Shipment.for_user(current_user).order(deliver_by: :asc)
    else
      @deliveries = Delivery.for_user(current_user)
      @trucks = Truck.for_company(current_company)
    end
  end
end
