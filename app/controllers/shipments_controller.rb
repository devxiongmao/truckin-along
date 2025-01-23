class ShipmentsController < ApplicationController
  before_action :set_company_resources, only: [ :new, :edit ]
  before_action :set_shipment, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /shipments
  def index
    @shipments = Shipment.for_company(current_company)
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

  private

    def set_company_resources
      @drivers  = User.for_company(current_company)
      @trucks   = Truck.for_company(current_company)
      @statuses = ShipmentStatus.for_company(current_company)
    end

    def set_shipment
      @shipment = Shipment.for_company(current_company).find(params.expect(:id))
    end

    def shipment_params
      params.require(:shipment).permit(
        :name, 
        :shipment_status_id, 
        :sender_name, 
        :sender_address, 
        :receiver_name, 
        :receiver_address, 
        :weight, 
        :length, 
        :width, 
        :height, 
        :boxes, 
        :truck_id, 
        :user_id, 
        :company_id)
    end
end
