Feature: Trucking Company Loading a Shipment to a Truck
  As a driver or admin of a trucking company
  I want to assign a claimed shipment to a truck
  So that I can prepare for efficient delivery

  Background:
    Given I am logged in as a customer user
    And I am on the customer offers page
    Then I should see offers for shipment "Electronics Package"
    When I accept the offer from "LogiCo Express" for shipment "Electronics Package"
    Then I should see a flash message "Offer was successfully accepted. All other offers for this shipment have been rejected."

  @javascript
  Scenario: Assign a shipment to a truck from the Truck Loading page
    Given I am logged in as a driver user
    And I am on the deliveries index page
    When I click "Truck Loading"
    Then I should see a "Add to Truck" button
    And I should see a "Please select a truck" option
    When I select "Volvo-FH16-2022(ABC-1234)" from "Truck"
    And I check "shipment_ids[]" in the row that contains "Electronics Package"
    And I click "Add to Truck"
    Then I should see a flash message "Shipments successfully assigned to truck."

