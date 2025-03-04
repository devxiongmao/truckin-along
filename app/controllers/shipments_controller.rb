class ShipmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shipment, only: %i[ show edit update destroy ]
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
    @statuses = current_user.role == "customer" ? [] : ShipmentStatus.for_company(current_company)
  end

  # POST /shipments
  def create
    @shipment = Shipment.new(shipment_params)
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
    shipment_ids = params[:shipment_ids].presence || []
    preference = current_company.shipment_action_preferences.find_by(action: "claimed_by_company")
    if shipment_ids.any?
      shipments = Shipment.where(id: shipment_ids)
      shipments.update_all(company_id: current_company.id)
      shipments.update_all(shipment_status_id: preference.shipment_status_id) if preference&.shipment_status_id
      flash[:notice] = "Selected shipments have been assigned to your company."
    else
      flash[:alert] = "No shipments were selected."
    end
    redirect_to deliveries_path
  end

  def assign_shipments_to_truck
    truck = Truck.find_by(id: params[:truck_id])
    shipment_ids = params[:shipment_ids]

    preference = current_company.shipment_action_preferences.find_by(action: "loaded_onto_truck")

    if truck && shipment_ids.present?
      shipments = Shipment.for_company(current_company).where(id: shipment_ids)
      shipments.update_all(truck_id: truck.id)
      shipments.update_all(shipment_status_id: preference.shipment_status_id) if preference&.shipment_status_id
      redirect_to load_truck_deliveries_path, notice: "Shipments successfully assigned to truck #{truck.display_name}."
    else
      redirect_to load_truck_deliveries_path, alert: "Please select a truck and at least one shipment."
    end
  end

  def initiate_delivery
    if InitiateDelivery.new(params, current_company).run
      redirect_to start_delivery_deliveries_path, notice: "Delivery successfully started!"
    else
      redirect_to start_delivery_deliveries_path, notice: "Something went wrong."
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

    def shipment_params
      params.require(:shipment).permit(
        :shipment_status_id,
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
