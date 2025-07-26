When('I click {string}') do |button_text|
  click_link_or_button button_text
  # Add a small wait to ensure the form submission completes
  sleep 1
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I leave {string} empty') do |field|
  fill_in field, with: ''
end

Then('I should see an error message') do
  expect(page).to have_content('error')
end

When('I check {string}') do |checkbox_label|
  check checkbox_label
end

When('I wait') do
  sleep 10
end

Given('I am on the root page') do
  visit root_path
end

Then('I should be redirected to the dashboard page') do
  expect(current_path).to eq(dashboard_path)
end
