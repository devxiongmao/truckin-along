Then('I should be on the company creation page') do
  expect(current_path).to eq(new_company_path)
end

Then('I should see a form with fields for the new company') do
  expect(page).to have_field('Company Name')
  expect(page).to have_field('Company Address')
  expect(page).to have_field("Company Phone Number")
end

Then('I should see a success message confirming the company was created') do
  expect(page).to have_content('Company created successfully.')
end
