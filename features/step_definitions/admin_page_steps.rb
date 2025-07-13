Given('I am on the admin page') do
  visit admin_index_path
end

Then('I should be redirected to the admin page') do
  expect(current_path).to eq(admin_index_path)
end
