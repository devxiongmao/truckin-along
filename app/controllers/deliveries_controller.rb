class DeliveriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @unassigned_shipments = Shipment.for_company(current_company).where(user_id: nil)
    @my_shipments = Shipment.for_company(current_company).where(user: current_user)
  end

  def truck_loading
    @unassigned_shipments = Shipment.for_company(current_company).where(truck_id: nil)
    @trucks = Truck.for_company(current_company)
  end
end
