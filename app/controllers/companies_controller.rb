class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin
  before_action :set_company, only: %i[edit update]

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)

    if @company.save
      current_user.company = @company
      current_user.save
      setup_company_defaults(@company)
      flash[:notice] = "Company created successfully."
      redirect_to root_path
    else
      flash.now[:alert] = "Failed to create company."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @company.update(company_params)
      flash[:notice] = "Company updated successfully."
      redirect_to root_path
    else
      flash.now[:alert] = "Failed to update company."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_company
    @company = Company.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Company not found."
    redirect_to root_path
  end

  def company_params
    params.require(:company).permit(:name, :address)
  end

  def setup_company_defaults(company)
    ## Create default shipment statuses
    ShipmentStatus.create!({ name: "Ready", locked_for_customers: false, closed: false, company_id: company.id })
    transit_status = ShipmentStatus.create!({ name: "In-Transit",locked_for_customers: true, closed: false, company_id: company.id })
    ShipmentStatus.create!({ name: "Delivered", locked_for_customers: true, closed: true, company_id: company.id })
    
    # Create default shipment action preferences
    company.shipment_action_preferences.create({ action: "out_for_delivery", shipment_status_id: transit_status.id})
  end
end
