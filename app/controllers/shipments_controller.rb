class ShipmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shipment, only: %i[ show edit update destroy copy close]

  # GET /shipments
  def index
    authorize Shipment
    @shipments = Shipment.where(user_id: current_user.id).order(deliver_by: :asc)
  end

  # GET /shipments/1
  def show
  end

  # GET /shipments/new
  def new
    @shipment = Shipment.new
    authorize @shipment
  end

  # GET /shipments/1/edit
  def edit
    authorize @shipment
    @statuses = current_user.role == "customer" ? [] : ShipmentStatus.for_company(current_company)
  end

  # POST /shipments
  def create
    @shipment = Shipment.new(shipment_params)
    @shipment.user = current_user

    authorize @shipment
    if @shipment.save
      redirect_to @shipment, notice: "Shipment was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /shipments/1
  def update
    authorize @shipment
    if @shipment.shipment_status&.closed
      return redirect_to @shipment, alert: "Shipment is closed, and currently locked for edits."
    end

    if current_user.customer? && @shipment.shipment_status&.locked_for_customers
      return redirect_to @shipment, alert: "Shipment is currently locked for edits."
    end

    if @shipment.update(shipment_params)
      redirect_to @shipment, notice: "Shipment was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /shipments/1
  def destroy
    authorize @shipment
    @shipment.destroy!
    redirect_to shipments_path, status: :see_other, notice: "Shipment was successfully destroyed."
  end

  def copy
    @new_shipment = @shipment.dup
    @new_shipment.name = "Copy of #{@shipment.name}"
    @new_shipment.truck_id = nil
    @new_shipment.shipment_status_id = nil
    @new_shipment.company_id = nil
    @shipment = @new_shipment
    authorize @shipment
  end

  def close
    authorize Shipment
    unless @shipment.latest_delivery_shipment.delivery.in_progress?
      return redirect_to delivery_path(@shipment.active_delivery), alert: "Delivery is not in progress."
    end

    if @shipment.receiver_address != @shipment.latest_delivery_shipment.receiver_address
      @shipment.latest_delivery_shipment.update!(delivered_date: Time.now)
      @shipment.update!({
        company_id: nil,
        shipment_status_id: nil,
        truck_id: nil })
      return redirect_to delivery_path(@shipment.active_delivery), alert: "Shipment successfully returned to shipment marketplace. Please remember to mark this delivery complete once all packages are delivered."
    end

    preference = current_company.shipment_action_preferences.find_by(action: "successfully_delivered")
    unless preference&.shipment_status_id
      return redirect_to delivery_path(@shipment.active_delivery), alert: "No preference set."
    end

    if preference.shipment_status_id == @shipment.shipment_status_id
      return redirect_to delivery_path(@shipment.active_delivery), alert: "Shipment is already closed."
    end

    @shipment.latest_delivery_shipment.update!(delivered_date: Time.now)
    @shipment.update!(shipment_status_id: preference.shipment_status_id)
    ShipmentDeliveryMailer.successfully_delivered_email(@shipment.id).deliver_later
    redirect_to delivery_path(@shipment.active_delivery), notice: "Shipment successfully closed."
  end

  def assign
    authorize Shipment
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
    authorize Shipment
    service = ScheduleDelivery.new(params, current_company)

    if service.run
      redirect_to load_truck_deliveries_path, notice: "Shipments successfully assigned to truck."
    else
      flash[:alert] = service.errors
      redirect_to load_truck_deliveries_path
    end
  end

  def initiate_delivery
    authorize Shipment
    if current_user.active_delivery.present?
      flash[:alert] = "Already on an active delivery"
      return redirect_to start_deliveries_path
    end

    service = InitiateDelivery.new(params, current_user, current_company)

    if service.run
      redirect_to service.delivery, notice: "Delivery was successfully created with #{service.delivery.shipments.count} shipments."
    else
      flash[:alert] = service.errors
      redirect_to start_deliveries_path
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

    def shipment_params
      if current_user.customer?
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
          :deliver_by)
      elsif current_user.admin?
        params.require(:shipment).permit(
          :shipment_status_id,
          :sender_address,
          :receiver_address,
          :weight,
          :length,
          :width,
          :height)
      elsif current_user.driver?
        params.require(:shipment).permit(
          :shipment_status_id,
          :weight,
          :length,
          :width,
          :height)
      else
        {}
      end
    end
end
