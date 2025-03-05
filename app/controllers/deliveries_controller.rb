class DeliveriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_driver
  before_action :set_delivery, only: :show

  def index
    @unassigned_shipments = Shipment.where(company_id: nil)
    @my_shipments = Shipment.where(company_id: current_company)
  end

  def show
  end

  def load_truck
    @unassigned_shipments = Shipment.for_company(current_company).where(truck_id: nil)
    @trucks = Truck.for_company(current_company).select(&:available?)
  end

  def start
    @trucks = Truck.for_company(current_company)
    @active_delivery = current_user.active_delivery
  end

  private
    def set_delivery
      @delivery = Delivery.for_user(current_user).find(params[:id])
    end
end
