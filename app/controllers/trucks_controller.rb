class TrucksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_truck, only: %i[ show edit update destroy create_form ]

  # GET /trucks/1
  def show
    authorize @truck
  end

  # GET /trucks/new
  def new
    @truck = Truck.new
    authorize @truck
  end

  # GET /trucks/1/edit
  def edit
    authorize @truck
  end

  # POST /trucks
  def create
    @truck = Truck.new(truck_params)
    authorize @truck

    if @truck.save
      redirect_to admin_index_path, notice: "Truck was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /trucks/1
  def update
    authorize @truck
    if @truck.update(truck_params)
      redirect_to admin_index_path, notice: "Truck was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /trucks/1
  def destroy
    authorize @truck
    @truck.destroy!
    redirect_to admin_index_path, status: :see_other, notice: "Truck was successfully destroyed."
  end

  # POST /trucks/1/create_form
  def create_form
    authorize @truck

    form = Form.new({
      user_id: current_user.id,
      company_id: current_company.id,
      truck_id: @truck.id,
      title: params[:title],
      form_type: "Maintenance",
      submitted_at: Time.now,
      content: {
        last_inspection_date: params[:last_inspection_date],
        mileage: params[:mileage],
        oil_changed: !params[:oil_changed].blank?,
        tire_pressure_checked: !params[:tire_pressure_checked].blank?,
        notes: params[:additional_notes]
      }
    })

    if form.save
      @truck.update(active: true)
      redirect_to dashboard_path, notice: "Maintenance form successfully submitted."
    else
      redirect_to request.referrer, alert: "Unable to save form."
    end
  end

  private
    def set_truck
      @truck = Truck.for_company(current_company).find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def truck_params
      params.expect(truck: [ :make, :model, :year, :vin, :license_plate, :mileage, :weight, :length, :width, :height, :company_id ])
    end
end
