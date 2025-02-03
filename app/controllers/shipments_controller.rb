class ShipmentsController < ApplicationController
  before_action :set_shipment, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  before_action :authorize_customer, only: [ :new, :create, :destroy, :index ]
  before_action :authorize_driver, only: [ :assign, :assign_shipments_to_truck ]
  before_action :authorize_edit_update, only: [ :edit, :update ]

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

    if shipment_ids.any?
      shipments = Shipment.where(id: shipment_ids)
      shipments.update_all(company_id: current_company.id)
      flash[:notice] = "Selected shipments have been assigned to your company."
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
      redirect_to truck_loading_deliveries_path, notice: "Shipments successfully assigned to truck #{truck.display_name}."
    else
      redirect_to truck_loading_deliveries_path, alert: "Please select a truck and at least one shipment."
    end
  end

  private

    def set_shipment
      @shipment = Shipment.find(params[:id])

      if current_user.customer?
        if @shipment.user_id != current_user.id
          flash[:alert] = "You are not authorized to access this shipment."
          redirect_to shipments_path
        end
      else
        if @shipment.claimed? && @shipment.company_id != current_user.company_id
          flash[:alert] = "You are not authorized to access this shipment."
          redirect_to deliveries_path
        end
      end
    end

    def authorize_edit_update
      return if current_user.customer?

      unless @shipment.company_id == current_user.company_id
        flash[:alert] = "You are not authorized to modify this shipment."
        redirect_to deliveries_path
      end
    end

    def authorize_customer
      unless current_user&.role == "customer"
        flash[:alert] = "You are not authorized to perform this action."
        redirect_to root_path
      end
    end

    def authorize_driver
      if current_user&.role == "customer"
        flash[:alert] = "You are not authorized to perform this action."
        redirect_to root_path
      end
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
