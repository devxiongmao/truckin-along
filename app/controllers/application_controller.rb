class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :redirect_unless_company_registered

  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def current_company
    current_user&.company
  end

  private

    def redirect_unless_company_registered
      return if user_signed_in? && current_user.customer?
      return if devise_controller? || controller_name.in?(%w[companies welcome])

      if user_signed_in? && !current_user.has_company?
        flash[:alert] = "You must register a company before accessing the application."
        redirect_to new_company_path
      end
    end

    def ensure_admin
      redirect_to(root_path, alert: "Not authorized.") unless current_user&.admin?
    end

    def authorize_customer
      unless current_user&.role == "customer"
        flash[:alert] = "You are not authorized to perform this action."
        redirect_to root_path
      end
    end

    def authorize_driver
      if current_user&.role == "customer"
        flash[:alert] = "You are not authorized to perform this action."
        redirect_to root_path
      end
    end

    def handle_record_not_found
      redirect_to(root_path, alert: "Not authorized.")
    end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :drivers_license, :role, :home_address ])
      devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :drivers_license, :role, :home_address ])
    end
end
