# Preview all emails at http://localhost:3000/rails/mailers/driver_mailer_mailer
class DriverMailerPreview < ActionMailer::Preview
  def send_temp_password
    user = User.new(
      email: "demo.driver@example.com",
      first_name: "Demo",
      last_name: "Driver"
    )
    temp_password = "Temp1234@Preview"
    DriverMailer.send_temp_password(user, temp_password)
  end
end
