class DriverManagementsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin
  
    def new
      @driver = User.new(role: "driver")
    end
  
    def create
      @driver = User.new(driver_params)
      @driver.role = "driver"
      if @driver.save
        redirect_to driver_managements_path, notice: "Driver account created successfully."
      else
        render :new, alert: "Unable to create driver account."
      end
    end
  
    def index
      @drivers = User.drivers
    end
  
    private
  
    def driver_params
      params.require(:user).permit(:first_name, :last_name, :drivers_license, :email, :password, :password_confirmation)
    end
  
    def ensure_admin
      redirect_to(root_path, alert: "Not authorized.") unless current_user&.admin?
    end
  end
  