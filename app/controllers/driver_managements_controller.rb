class DriverManagementsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin

    before_action :set_driver, only: %i[edit update]

    def index
      @drivers = User.for_company(current_company).drivers
    end

    def new
      @driver = User.new(role: "driver")
    end

    def create
      @driver = User.new(driver_params)
      @driver.role = "driver"
      if @driver.save
        redirect_to driver_managements_path, notice: "Driver account created successfully."
      else
        render :new, status: :unprocessable_entity, alert: "Unable to create driver account."
      end
    end

    def edit; end

    def update
      if @driver.update(driver_params)
        redirect_to driver_managements_path, notice: "Driver was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_driver
      @driver = User.for_company(current_company).find(params[:id])
    end

    def driver_params
      params.require(:user).permit(:company_id, :first_name, :last_name, :drivers_license, :email, :password, :password_confirmation)
    end

    def ensure_admin
      redirect_to(root_path, alert: "Not authorized.") unless current_user&.admin?
    end
end
