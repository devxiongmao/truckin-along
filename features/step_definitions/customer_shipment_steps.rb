Given('I am on the customer shipment page') do
  visit shipments_path
end

When('I click the {string} link for shipment {string}') do |link_text, shipment_name|
  row = find('tr', text: shipment_name)
  within(row) { click_link link_text }
end

Then('I should be on the new shipment creation form') do
  expect(current_path).to eq(new_shipment_path)
end

Then('I should see a form with fields for shipment information') do
  expect(page).to have_field('Name')
  expect(page).to have_field('Sender name')
  expect(page).to have_field('Sender address')
  expect(page).to have_field('Receiver name')
  expect(page).to have_field('Receiver address')
  expect(page).to have_field('Weight (kg)')
  expect(page).to have_field('Length (cm)')
  expect(page).to have_field('Height (cm)')
  expect(page).to have_field('Deliver By')
end

Then('I should be redirected to the shipment show page') do
  expect(current_path).to eq(shipment_path(Shipment.last.id))
end

Then('I should see a success message confirming the shipment was created') do
  expect(page).to have_content('Shipment was successfully created.')
end

Then('I should remain on the new shipment creation form') do
  # When validation fails, the form is re-rendered at the POST path
  expect(current_path).to eq(new_shipment_path)
end

Then('the previously entered shipment information should still be present') do
  expect(page).to have_field('Name', with: 'Documents')
  expect(page).to have_field('Sender name', with: "Peter Parker")
  expect(page).to have_field('Receiver name', with: "Clark Kent")
  expect(page).to have_field('Receiver address', with: "123 Main St, Anytown, USA")
  expect(page).to have_field('Weight (kg)', with: '1')
end

Then('I should see the shipment map') do
  expect(page).to have_css('#shipment-map')
end
