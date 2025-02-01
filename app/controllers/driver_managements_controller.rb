class DriverManagementsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin

    before_action :set_driver, only: %i[edit update]

    def new
      @driver = User.new(role: "driver")
    end

    def create
      @driver = User.new(driver_params)
      @driver.role = "driver"
      @driver.company = current_user.company
      if @driver.save
        redirect_to admin_index_path, notice: "Driver account created successfully."
      else
        render :new, status: :unprocessable_entity, alert: "Unable to create driver account."
      end
    end

    def edit; end

    def update
      if @driver.update(driver_params)
        redirect_to admin_index_path, notice: "Driver was successfully updated."
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
end
