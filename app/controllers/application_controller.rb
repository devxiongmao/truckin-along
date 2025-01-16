class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :redirect_unless_company_registered

  private

  def redirect_unless_company_registered
    return if devise_controller? || controller_name.in?(%w[companies welcome])

    if user_signed_in? && !current_user.has_company?
      flash[:alert] = "You must register a company before accessing the application."
      redirect_to new_company_path
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :drivers_license, :company_name, :company_address ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :drivers_license ])
  end
end