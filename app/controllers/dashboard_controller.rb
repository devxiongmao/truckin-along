class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.customer?
      @shipments = Shipment.for_user(current_user)
    else
      @deliveries = Delivery.for_user(current_user)
    end
  end
end
