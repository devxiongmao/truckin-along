Then('I should be on the new driver creation form') do
  expect(current_path).to eq(new_driver_management_path)
end

Then('I should see a form with fields for driver information') do
  expect(page).to have_field('First Name')
  expect(page).to have_field('Last Name')
  expect(page).to have_field("Driver's License")
  expect(page).to have_field('Email')
end

Then('I should see a success message confirming the driver was created') do
  expect(page).to have_content('Driver account created successfully')
end

Then('I should remain on the new driver creation form') do
  # When validation fails, the form is re-rendered at the POST path
  expect(current_path).to eq(new_driver_management_path)
end

Then('the previously entered driver info should still be present') do
  expect(page).to have_field('First Name', with: 'Jane')
  expect(page).to have_field('Last Name', with: 'Smith')
  expect(page).to have_field('Email', with: 'jane.smith@example.com')
end

Then('the driver should have {string} as their license number') do |license|
  expect(page).to have_content(license)
end

Then('the driver form should be empty and ready for input') do
  # Check that the form fields exist and are empty
  expect(page).to have_field('First Name')
  expect(page).to have_field('Last Name')
  expect(page).to have_field("Driver's License")
  expect(page).to have_field('Email')

  # Verify the fields are empty by checking their values
  expect(find_field('First Name').value.to_s).to eq("")
  expect(find_field('Last Name').value.to_s).to eq("")
  expect(find_field("Driver's License").value.to_s).to eq("")
  expect(find_field('Email').value.to_s).to eq("")
end
