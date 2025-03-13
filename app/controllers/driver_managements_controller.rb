class DriverManagementsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_driver, only: %i[edit update]

    def new
      authorize :driver_management, :new?
      @driver = User.new(role: "driver")
    end

    def create
      authorize :driver_management, :create?
      @driver = User.new(driver_params)
      @driver.role = "driver"
      @driver.company = current_user.company
      if @driver.save
        redirect_to admin_index_path, notice: "Driver account created successfully."
      else
        render :new, status: :unprocessable_entity, alert: "Unable to create driver account."
      end
    end

    def edit
      authorize :driver_management, :edit?
    end

    def update
      authorize :driver_management, :update?
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
      params.require(:user).permit(:first_name, :last_name, :home_address, :drivers_license, :email, :password, :password_confirmation)
    end
end
