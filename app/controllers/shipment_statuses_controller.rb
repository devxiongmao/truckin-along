class ShipmentStatusesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_shipment_status, only: %i[edit update destroy]

    def new
      @shipment_status = ShipmentStatus.new
      authorize @shipment_status
    end

    def create
      @shipment_status = ShipmentStatus.new(shipment_status_params)
      authorize @shipment_status
      if @shipment_status.save
        redirect_to admin_index_path, notice: "Shipment status was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @shipment_status
    end

    def update
      authorize @shipment_status
      if @shipment_status.update(shipment_status_params)
        redirect_to admin_index_path, notice: "Shipment status was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @shipment_status
      @shipment_status.destroy
      redirect_to admin_index_path, notice: "Shipment status was successfully destroyed."
    end

    private

    def set_shipment_status
      @shipment_status = ShipmentStatus.for_company(current_company).find(params[:id])
    end

    def shipment_status_params
      params.require(:shipment_status).permit(:company_id, :name, :locked_for_customers, :closed).tap do |whitelisted|
        whitelisted[:locked_for_customers] = ActiveRecord::Type::Boolean.new.cast(whitelisted[:locked_for_customers])
        whitelisted[:closed] = ActiveRecord::Type::Boolean.new.cast(whitelisted[:closed])
      end
    end
end
