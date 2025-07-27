Then('I should be on the new customer creation form') do
  expect(current_path).to eq(new_customer_registration_path)
end

Then ('I should be on the new admin creation form') do
  expect(current_path).to eq(new_user_registration_path)
end

Then('I should see a form with fields for customer creation') do
  expect(page).to have_field('First Name')
  expect(page).to have_field('Last Name')
  expect(page).to have_field("Home address")
  expect(page).to have_field('Email')
  expect(page).to have_field('Password')
  expect(page).to have_field('Confirm Password')
end

Then('I should see a form with fields for admin creation') do
  expect(page).to have_field('First Name')
  expect(page).to have_field('Last Name')
  expect(page).to have_field("Home address")
  expect(page).to have_field("Driver's License")
  expect(page).to have_field('Email')
  expect(page).to have_field('Password')
  expect(page).to have_field('Confirm Password')
end

Then('I should see a success message confirming the user was created') do
  expect(page).to have_content('Welcome! You have signed up successfully.')
end
