class ShipmentStatusesController < ApplicationController
    before_action :set_shipment_status, only: %i[show edit update destroy]
  
    def index
      @shipment_statuses = ShipmentStatus.all
    end
  
    def show; end
  
    def new
      @shipment_status = ShipmentStatus.new
    end
  
    def create
      @shipment_status = ShipmentStatus.new(shipment_status_params)
      if @shipment_status.save
        redirect_to @shipment_status, notice: 'Shipment status was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    def edit; end
  
    def update
      if @shipment_status.update(shipment_status_params)
        redirect_to @shipment_status, notice: 'Shipment status was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
  
    def destroy
      @shipment_status.destroy
      redirect_to shipment_statuses_url, notice: 'Shipment status was successfully destroyed.'
    end
  
    private
  
    def set_shipment_status
      @shipment_status = ShipmentStatus.find(params[:id])
    end
  
    def shipment_status_params
      params.require(:shipment_status).permit(:name)
    end
  end
  