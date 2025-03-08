class DeliveriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_driver
  before_action :set_delivery, only: [ :show, :close ]

  def index
    @unassigned_shipments = Shipment.where(company_id: nil)
    @my_shipments = Shipment.where(company_id: current_company)
  end

  def show
  end

  def close
    if @delivery.can_be_closed?
      @delivery.update!(status: :completed)
      return redirect_to start_deliveries_path, notice: "Delivery complete!"
    end
    
    redirect_to delivery_path(@delivery)
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
