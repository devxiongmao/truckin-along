Feature: Trucking Company Claiming a Shipment
  As a driver or admin of a trucking company
  I want to browse shipments and submit bids
  So that I can claim shipments for delivery

  Background:
    Given I am logged in as a driver user with email "jane.smith@logico.com"
    And I am on the deliveries index page

  @javascript
  Scenario: Browse marketplace and submit a bid for a shipment
    Then I should see a "Submit Bids" button
    And I click "Show Details" in the row that contains "Electronics Package"
    Then I should see the shipment map
    When I click "Shipment Marketplace"
    And I check "shipment_ids[]"
    And I click "Submit Bids"
    And I fill in "Offer Price ($):" with "50"
    And I fill in "Notes:" with "Fast and reliable"
    And I click "Create Offers"
    Then I should see a flash message "1 offers were successfully created."
    
    When I withdraw my offer for shipment "Electronics Package"
    Then I should see a flash message "Offer was successfully withdrawn."

    When I click "Shipment Marketplace"
    And I check "shipment_ids[]"
    And I click "Submit Bids"
    And I fill in "Offer Price ($):" with "40"
    And I fill in "Notes:" with "Fast, reliable and cheap"
    And I click "Create Offers"
    Then I should see a flash message "1 offers were successfully created."
