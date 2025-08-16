Feature: Driver Setting a Shipment to Closed
  As a driver or admin of a trucking company
  I want to mark delivered shipments as delivered
  So that I can get payment from users.

  Background:
    Given I am logged in as a driver user with email "michael.jordan@logico.com"
    And I am on the deliveries start page

  Scenario: Mark a shipment as delivered via Quick Close
    When I click "View Delivery"
    Then I should be on the delivery show page
    And I should see a "Quick Close" link for each shipment
    When I click "Quick Close" for a shipment
    And I accept the confirmation dialog
    Then I should be on the delivery show page
    And I should see a success message "Shipment successfully closed."

  Scenario: Mark a shipment as delivered via Manual Edit
    When I click "View Delivery"
    Then I should be on the delivery show page
    And I should see a "Edit" link for each shipment
    When I click "Edit" for a shipment
    Then I should be on the shipment edit page
    When I select "Delivered" from "Shipment Status"
    And I click "Save Shipment"
    Then I should be redirected to the shipment show page
    And I should see a success message "Shipment was successfully updated."

