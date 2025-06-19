class DeliveriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_delivery, only: [ :show, :close ]

  def index
    authorize Delivery
    @unassigned_shipments = Shipment.where(company_id: nil).without_active_delivery.order(deliver_by: :asc)
    @my_shipments = Shipment.where(company_id: current_company).order(deliver_by: :asc)
  end

  def show
    authorize @delivery
    @open_shipments = @delivery.open_shipments.distinct
    @delivered_shipments = @delivery.delivered_shipments.distinct

    @shipment_status = ShipmentActionPreference
                       .includes(:shipment_status)
                       .find_by(action: "successfully_delivered", company_id: current_company.id)
                       &.shipment_status
  end

  def close
    authorize @delivery

    result = CloseDelivery.new(@delivery, odometer_params).call

    if result.success?
      redirect_to start_deliveries_path, notice: result.message
    else
      redirect_to delivery_path(@delivery), alert: result.error
    end
  end

  def load_truck
    authorize Delivery
    @unassigned_shipments = Shipment.for_company(current_company).where(truck_id: nil).order(deliver_by: :asc)
    @trucks = Truck.for_company(current_company).active?.select(&:available?)
  end

  def start
    authorize Delivery
    @trucks = Truck.for_company(current_company).active?
    @active_delivery = current_user.active_delivery
  end

  private
    def set_delivery
      @delivery = Delivery.find(params[:id])
    end

    def odometer_params
      { odometer_reading: params[:odometer_reading].to_i }
    end
end
