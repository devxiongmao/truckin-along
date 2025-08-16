Given('I am on the deliveries index page') do
  visit deliveries_path
end

Given('I am on the deliveries start page') do
  visit start_deliveries_path
end

When('I check all required inspection checkboxes') do
  within('#initiate-modal') do
    # Scroll to the bottom of the modal to ensure all elements are accessible
    page.execute_script("document.getElementById('initiate-modal').scrollTop = document.getElementById('initiate-modal').scrollHeight")

    all('input[type="checkbox"]').each_with_index do |checkbox, index|
      # Scroll the checkbox into view before checking
      page.execute_script("arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});", checkbox)
      # Small wait to ensure scrolling completes
      sleep 0.1
      checkbox.check
    end

    all('input[type="checkbox"]').each do |checkbox|
      expect(checkbox).to be_checked
    end
  end
end

When('I click {string} for a shipment') do |button_text|
  # Find the first shipment row in the table and click the button/link within that context
  within('table.styled-table tbody tr:first-child') do
    click_link_or_button button_text
  end
end

When('I enter {string} in the odometer reading field') do |odometer_value|
  within('[data-complete-delivery-target="modal"]') do
    fill_in('odometer-reading', with: odometer_value)
  end
end

When('I submit the completion form') do
  within('[data-complete-delivery-target="modal"]') do
    find('button[data-action="click->complete-delivery#submitWithOdometer"]').click
  end
end

When('I click "Yes" in the confirmation modal') do
  within('[data-complete-delivery-target="modal"]') do
    find('[data-complete-delivery-target="confirmBtn"]').click
  end
end

Then('I should see a pre-delivery inspection modal') do
  expect(page).to have_css('#initiate-modal')
  expect(page).to have_content('Pre-Delivery Inspection Checklist')
  expect(page).not_to have_css('#initiate-modal.hidden')
  expect(page).to have_field('modal-truck-id', type: 'hidden')
end

Then('I should see a success message confirming the delivery was created') do
  expect(page).to have_content('Delivery was successfully created')
end

Then('I should be on the delivery show page') do
  expect(current_path).to match(/\/deliveries\/\d+/)
end

Then('I should be on the deliveries start page') do
  expect(current_path).to match(/\/deliveries\/start/)
end

Then('I should see a {string} link for each shipment') do |link_text|
  expect(page).to have_link(link_text)
end

Then('I should be on the shipment edit page') do
  expect(current_path).to match(/\/shipments\/\d+\/edit/)
end

Then('I should see a confirmation modal') do
  expect(page).to have_css('[data-complete-delivery-target="modal"]')
  expect(page).to have_content('Mark this delivery as complete?')
end

Then('I should see an odometer reading field') do
  within('[data-complete-delivery-target="modal"]') do
    expect(page).to have_css('[data-complete-delivery-target="odometerContainer"]')
    expect(page).to have_field('odometer-reading', type: 'number')
  end
end

Then('I should see an error message {string}') do |message|
  expect(page).to have_content(message)
end
