Then('I should be on the new user creation form') do
  expect(current_path).to eq(new_customer_registration_path)
end

Then('I should see a form with fields for user creation') do
  expect(page).to have_field('First Name')
  expect(page).to have_field('Last Name')
  expect(page).to have_field("Home address")
  expect(page).to have_field('Email')
  expect(page).to have_field('Password')
  expect(page).to have_field('Confirm Password')
end

Then('I should see a success message confirming the user was created') do
  expect(page).to have_content('Welcome! You have signed up successfully.')
end
