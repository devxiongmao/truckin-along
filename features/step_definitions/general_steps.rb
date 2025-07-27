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

When('I check {string}') do |checkbox_label|
  check checkbox_label
end

When('I click {string} in the row that contains {string}') do |button_text, row_identifier|
  table_row = find(:xpath, "//tr[td[contains(text(), '#{row_identifier}')]]")
  within(table_row) do
    click_link_or_button button_text
  end
end

Then('I should see an error message') do
  expect(page).to have_content('error')
end

Then('the new record, {string}, should be listed under the {string} section') do |name, section|
  expect(page).to have_content(section)
  expect(page).to have_content(name)
end

Then('the text, {string}, should be in the row next the text, {string}') do |first_text, second_text|
  table_row = find(:xpath, "//tr[td[contains(text(), '#{first_text}')] and td[contains(text(), '#{second_text}')]]")
  expect(table_row).not_to be_nil
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
