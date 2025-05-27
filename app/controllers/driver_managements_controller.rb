class DriverManagementsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_driver, only: %i[edit update reset_password]

    def new
      authorize :driver_management, :new?
      @driver = User.new(role: "driver")
    end

    def create
      authorize :driver_management, :create?
      temp_password = Devise.friendly_token.first(12)

      @driver = User.new(driver_params)
      @driver.password = temp_password
      @driver.password_confirmation = temp_password

      @driver.role = "driver"
      @driver.company = current_user.company

      if @driver.save
        DriverMailer.send_temp_password(@driver, temp_password).deliver_later
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

    def reset_password
      authorize :driver_management, :reset_password?

      temp_password = Devise.friendly_token.first(12)

      @driver.password = temp_password
      @driver.password_confirmation = temp_password
      if @driver.save
        DriverMailer.send_reset_password(@driver, temp_password).deliver_later
        redirect_to admin_index_path, notice: "Driver password was successfully reset."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_driver
      @driver = User.for_company(current_company).find(params[:id])
    end

    def driver_params
      params.require(:user).permit(:first_name, :last_name, :home_address, :drivers_license, :email)
    end
end
