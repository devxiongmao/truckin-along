class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.persisted?
        byebug
        resource.role = params.dig(:user, :role) || "admin"
        resource.save
      end
    end
  end

  def new_customer
    @user = User.new(role: "customer")
    render :new
  end
end
