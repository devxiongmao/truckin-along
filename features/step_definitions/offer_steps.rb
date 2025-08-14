Given('I am on the customer offers page') do
  visit offers_path
end

Then('I should be on the customer offers page') do
  expect(current_path).to eq(offers_path)
end

Then('I should see offers for shipment {string}') do |shipment_name|
  expect(page).to have_css('.shipment-offers-section .shipment-title', text: shipment_name)
end

When('I reject the offer from {string} for shipment {string}') do |company_name, shipment_name|
  section = find('.shipment-offers-section', text: shipment_name)
  within(section) do
    row = find('tr', text: company_name)
    accept_confirm do
      within(row) { click_link 'Reject' }
    end
  end
end

When('I accept the offer from {string} for shipment {string}') do |company_name, shipment_name|
  section = find('.shipment-offers-section', text: shipment_name)
  within(section) do
    row = find('tr', text: company_name)
    accept_confirm do
      within(row) { click_link 'Accept' }
    end
  end
end

Then('I should see a flash message {string}') do |message|
  expect(page).to have_content(message)
end

Then('I should see {int} offers for shipment {string}') do |expected_count, shipment_name|
  section = find('.shipment-offers-section', text: shipment_name)
  within(section) do
    expect(page).to have_css('tbody tr', count: expected_count)
  end
end

When('I withdraw my offer for shipment {string}') do |shipment_name|
  row = find('tr', text: shipment_name)
  within(row) do
    accept_confirm do
      click_link 'Withdraw'
    end
  end
end
