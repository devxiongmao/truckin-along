class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.persisted?
        resource.role = params.dig(:user, :role) || "admin"
        resource.save
      end
    end
  end

  def new_customer
    @user = User.new(role: "customer")
    render :new
  end

  protected

  def after_sign_in_path_for(resource)
    dashboard_path
  end
end
