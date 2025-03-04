class DeliveriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_driver
  before_action :has_active_delivery?

  def index
    @unassigned_shipments = Shipment.where(company_id: nil)
    @my_shipments = Shipment.where(company_id: current_company)
  end

  def load_truck
    @unassigned_shipments = Shipment.for_company(current_company).where(truck_id: nil)
    ## Only show trucks that don't have an active delivery
    @trucks = Truck.for_company(current_company)
  end

  def start_delivery
    @trucks = Truck.for_company(current_company)
    @active_delivery = current_user.active_delivery
  end
end
