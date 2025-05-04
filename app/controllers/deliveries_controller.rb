class DeliveriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_delivery, only: [ :show, :close ]

  def index
    authorize Delivery
    @unassigned_shipments = Shipment.where(company_id: nil).without_active_delivery
    @my_shipments = Shipment.where(company_id: current_company)
  end

  def show
    authorize @delivery
  end

  def close
    authorize @delivery
    if @delivery.can_be_closed?
      @delivery.update!(status: :completed)
      return redirect_to start_deliveries_path, notice: "Delivery complete!"
    end

    redirect_to delivery_path(@delivery), alert: "Delivery still has open shipments. It cannot be closed at this time."
  end

  def load_truck
    authorize Delivery
    @unassigned_shipments = Shipment.for_company(current_company).where(truck_id: nil)
    @trucks = Truck.for_company(current_company).active?.select(&:available?)
  end

  def start
    authorize Delivery
    @trucks = Truck.for_company(current_company).active?
    @active_delivery = current_user.active_delivery
  end

  private
    def set_delivery
      @delivery = Delivery.for_user(current_user).find(params[:id])
    end
end
