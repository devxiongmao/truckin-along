class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, only: %i[edit update]

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)

    if @company.save
      current_user.company = @company
      current_user.save
      flash[:notice] = "Company created successfully."
      redirect_to edit_company_path(@company)
    else
      flash.now[:alert] = "Failed to create company."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @company.update(company_params)
      flash[:notice] = "Company updated successfully."
      redirect_to edit_company_path(@company)
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
end
