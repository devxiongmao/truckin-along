class DeliveriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @unassigned_shipments = Shipment.where(company_id: nil)
    @my_shipments = Shipment.where(company_id: current_company)
  end

  def create 
    @delivery = Delivery.new(delivery_params)
    if @delivery.save
      flash[:notice] = "Delivery initiated successfully."
      redirect_to root_path
    else
      flash.now[:alert] = "Failed to initiate delivery."
      render :start_delivery, status: :unprocessable_entity
    end
  end

  def truck_loading
    @unassigned_shipments = Shipment.for_company(current_company).where(truck_id: nil)
    @trucks = Truck.for_company(current_company)
  end

  def start_delivery
    @trucks = Truck.for_company(current_company)
    @active_delivery = current_user.active_delivery
  end

  private

  def delivery_params
    params.require(:delivery).permit(:user_id, :truck_id, :status)
  end
end
