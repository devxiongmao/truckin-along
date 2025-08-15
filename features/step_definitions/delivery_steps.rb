Given('I am on the deliveries index page') do
  visit deliveries_path
end

Given('I am on the deliveries start page') do
  visit start_deliveries_path
end

Then('I should see a pre-delivery inspection modal') do
  expect(page).to have_css('#initiate-modal')
  expect(page).to have_content('Pre-Delivery Inspection Checklist')
  # Verify the modal is visible (not hidden)
  expect(page).not_to have_css('#initiate-modal.hidden')
  # Verify the truck ID is set in the hidden field
  expect(page).to have_field('modal-truck-id', type: 'hidden')
end

When('I check all required inspection checkboxes') do
  # First, ensure we're working within the modal
  within('#initiate-modal') do
    # Scroll to the bottom of the modal to ensure all elements are accessible
    page.execute_script("document.getElementById('initiate-modal').scrollTop = document.getElementById('initiate-modal').scrollHeight")

    # Use the development mode "Check All" button for reliability
    if page.has_button?('✓ Check All (DEV)')
      click_button '✓ Check All (DEV)'
    else
      # Fallback: manually check all checkboxes with proper scrolling
      all('input[type="checkbox"]').each_with_index do |checkbox, index|
        # Scroll the checkbox into view before checking
        page.execute_script("arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});", checkbox)
        # Small wait to ensure scrolling completes
        sleep 0.1
        checkbox.check
      end
    end

    # Verify all checkboxes are checked
    all('input[type="checkbox"]').each do |checkbox|
      expect(checkbox).to be_checked
    end
  end
end

Then('I should see a success message confirming the delivery was created') do
  expect(page).to have_content('Delivery was successfully created')
end

Then('I should be redirected to the delivery show page') do
  expect(current_path).to match(/\/deliveries\/\d+/)
end

Then('I should see {string} in the trucks table') do |truck_name|
  expect(page).to have_content(truck_name)
  # Also verify it's in the trucks table specifically
  within('#my-shipments') do
    expect(page).to have_content(truck_name)
  end
end
