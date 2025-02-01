class ShipmentsController < ApplicationController
  before_action :set_shipment, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /shipments
  def index
    @shipments = Shipment.where(user_id: current_user.id)
  end

  # GET /shipments/1
  def show
  end

  # GET /shipments/new
  def new
    @shipment = Shipment.new
  end

  # GET /shipments/1/edit
  def edit
  end

  # POST /shipments
  def create
    @shipment = Shipment.new(shipment_params)
    @shipment.shipment_status = ShipmentStatus.find_by(name: "Ready")
    @shipment.user = current_user

    if @shipment.save
      redirect_to @shipment, notice: "Shipment was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /shipments/1
  def update
    if @shipment.update(shipment_params)
      redirect_to @shipment, notice: "Shipment was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /shipments/1
  def destroy
    @shipment.destroy!
    redirect_to shipments_path, status: :see_other, notice: "Shipment was successfully destroyed."
  end

  def assign
    shipment_ids = params[:shipment_ids] || []
    shipments = Shipment.for_company(current_company).where(id: shipment_ids, user_id: nil)
    shipments.update_all(user_id: current_user.id)

    if shipment_ids.any?
      flash[:notice] = "Selected shipments have been assigned to you."
    else
      flash[:alert] = "No shipments were selected."
    end

    redirect_to deliveries_path
  end

  def assign_shipments_to_truck
    truck = Truck.find_by(id: params[:truck_id])
    shipment_ids = params[:shipment_ids]

    if truck && shipment_ids.present?
      Shipment.for_company(current_company).where(id: shipment_ids).update_all(truck_id: truck.id)
      redirect_to shipments_path, notice: "Shipments successfully assigned to truck #{truck.display_name}."
    else
      redirect_to shipments_path, alert: "Please select a truck and at least one shipment."
    end
  end

  private

    def set_shipment
      @shipment = Shipment.find(params.expect(:id))
    end

    def shipment_params
      params.require(:shipment).permit(
        :name,
        :sender_name,
        :sender_address,
        :receiver_name,
        :receiver_address,
        :weight,
        :length,
        :width,
        :height,
        :boxes
        )
    end
end
