class TrucksController < ApplicationController
  before_action :set_truck, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /trucks
  def index
    @trucks = Truck.all
  end

  # GET /trucks/1
  def show
  end

  # GET /trucks/new
  def new
    @truck = Truck.new
  end

  # GET /trucks/1/edit
  def edit
  end

  # POST /trucks
  def create
    @truck = Truck.new(truck_params)
    if @truck.save
      redirect_to @truck, notice: "Truck was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /trucks/1
  def update
    if @truck.update(truck_params)
      redirect_to @truck, notice: "Truck was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /trucks/1
  def destroy
    @truck.destroy!
    redirect_to trucks_path, status: :see_other, notice: "Truck was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_truck
      @truck = Truck.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def truck_params
      params.expect(truck: [ :make, :model, :year, :mileage ])
    end
end
