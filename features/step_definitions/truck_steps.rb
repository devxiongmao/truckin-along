Then('I should be on the new truck creation form') do
  expect(current_path).to eq(new_truck_path)
end

Then('I should see a form with fields for truck information') do
  expect(page).to have_field('Make')
  expect(page).to have_field('Model')
  expect(page).to have_field('Year')
  expect(page).to have_field('Mileage')
  expect(page).to have_field('VIN #')
  expect(page).to have_field('License Plate')
  expect(page).to have_field('Haul Weight (kg)')
  expect(page).to have_field('Length of Bed (cm)')
  expect(page).to have_field('Width of Bed (cm)')
  expect(page).to have_field('Height of Bed (cm)')
end

Then('I should see a success message confirming the truck was created') do
  expect(page).to have_content('Truck created successfully')
end

Then('the new truck, {string}, should be listed under the {string} section') do |truck_name, section|
  expect(page).to have_content(section)
  # Check for the truck's name in the table
  expect(page).to have_content(truck_name)
end

Then('I should remain on the new truck creation form') do
  # When validation fails, the form is re-rendered at the POST path
  expect(current_path).to eq(trucks_path)
end

Then('the previously entered information should still be present') do
  expect(page).to have_field('Make', with: 'Chevrolet')
  expect(page).to have_field('Model', with: 'Silverado')
  expect(page).to have_field('Year', with: '2022')
  expect(page).to have_field('License Plate', with: 'XYZ789')
  expect(page).to have_field('Haul Weight (kg)', with: '1200')
end

Then('the truck should have {string} as its VIN number') do |vin|
  expect(page).to have_content(vin)
end

Then('the form should be empty and ready for input') do
  # Check that the form fields exist and are empty
  expect(page).to have_field('Make')
  expect(page).to have_field('Model')
  expect(page).to have_field('Year')
  expect(page).to have_field('Mileage')
  expect(page).to have_field('VIN #')
  expect(page).to have_field('License Plate')
  expect(page).to have_field('Haul Weight (kg)')
  expect(page).to have_field('Length of Bed (cm)')
  expect(page).to have_field('Width of Bed (cm)')
  expect(page).to have_field('Height of Bed (cm)')

  # Verify the fields are empty by checking their values
  expect(find_field('Make').value).to be_nil
  expect(find_field('Model').value).to be_nil
  expect(find_field('Year').value).to be_nil
  expect(find_field('Mileage').value).to be_nil
  expect(find_field('VIN #').value).to be_nil
  expect(find_field('License Plate').value).to eq("")
  expect(find_field('Haul Weight (kg)').value).to be_nil
  expect(find_field('Length of Bed (cm)').value).to be_nil
  expect(find_field('Width of Bed (cm)').value).to be_nil
  expect(find_field('Height of Bed (cm)').value).to be_nil
end

Given('a truck {string} exists in the system') do |truck_name|
  # Parse truck name to extract make and model
  make, model = truck_name.split(' ', 2)
  create(:truck, make: make, model: model)
end

When('I click {string} next to the {string} truck') do |button_text, truck_name|
  # Find the truck row and click the maintenance button
  within("tr", text: truck_name) do
    click_link_or_button button_text
  end
end

Then('I should see a maintenance form modal') do
  expect(page).to have_css('.modal')
  expect(page).to have_content('Maintenance Form')
end

Then('the modal should have fields for maintenance information') do
  expect(page).to have_field('Maintenance Title')
  expect(page).to have_field('Date of Completion')
  expect(page).to have_field('Current Mileage')
  expect(page).to have_field('Oil Change')
  expect(page).to have_field('Tire Pressure Check')
  expect(page).to have_field('Notes')
end

Then('the maintenance should be successfully recorded') do
  # Verify the maintenance was saved to the database
  expect(page).to have_content('Maintenance recorded successfully')
end

Then('I should see a confirmation message') do
  expect(page).to have_content('Maintenance completed')
end
