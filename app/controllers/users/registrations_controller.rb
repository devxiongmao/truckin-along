class Users::RegistrationsController < Devise::RegistrationsController
    def create
      super do |resource|
        if resource.persisted?
          resource.role = "admin"
          resource.save
        end
      end
    end
end
