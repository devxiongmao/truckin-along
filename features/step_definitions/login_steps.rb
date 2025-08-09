Given('I am logged in as an admin user') do
  admin = User.find_by!(email: "john.doe@example.com")
  login_as(admin, scope: :user)
end

Given('I am logged in as a driver user') do
  driver = User.find_by!(email: "jane.smith@example.com")
  login_as(driver, scope: :user)
end

Given('I am logged in as a customer user') do
  customer = User.find_by!(email: "peter.parker@example.com")
  login_as(customer, scope: :user)
end
