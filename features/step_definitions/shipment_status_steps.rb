Then('I should be on the new shipment status creation form') do
  expect(current_path).to eq(new_shipment_status_path)
end

Then('I should be on the shipment action preference form page') do
  expect(current_path).to eq(edit_shipment_action_preference_path(1))
end

Then('I should see a form with fields for shipment status information') do
  expect(page).to have_field('Name')
  expect(page).to have_field('Lock for Customers?')
  expect(page).to have_field("Mark as Closed?")
end

Then('I should see a success message confirming the shipment status was created') do
  expect(page).to have_content('Shipment status was successfully created.')
end

Then('I should see a success message confirming the shipment action preference was saved') do
  expect(page).to have_content('Preference was successfully updated.')
end
