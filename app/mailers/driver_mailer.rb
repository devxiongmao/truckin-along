class DriverMailer < ApplicationMailer
  def send_temp_password(user, temp_password)
    @user = user
    @temp_password = temp_password
    mail(to: @user.email, subject: "Your Account Has Been Created")
  end
end
