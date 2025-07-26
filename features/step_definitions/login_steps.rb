Given('I am logged in as an admin user') do
  company = create(:company)
  admin = create(:user, :admin, company: company)
  login_as(admin, scope: :user)
end

Given('I am logged in as an driver user') do
  company = create(:company)
  driver = create(:user, :driver, company: company)
  login_as(driver, scope: :user)
end

Given('I am logged in as an customer user') do
  customer = create(:user, :customer, company: company)
  login_as(customer, scope: :user)
end
