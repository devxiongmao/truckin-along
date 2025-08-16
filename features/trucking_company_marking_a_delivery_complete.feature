Feature: Trucking Company Marking a Delivery Complete
  As a driver or admin of a trucking company
  I want to mark deliveries as complete
  So that I can accurately manage my in progress deliveries

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
    And I wait for 2 seconds

    And I should see a "Mark Complete" button
    When I click "Mark Complete"
    Then I should see a confirmation modal
    When I click "Yes" in the confirmation modal
    Then I should see an odometer reading field
    When I enter "125000" in the odometer reading field
    And I submit the completion form
    Then I should be on the deliveries start page
    And I should see a success message "Delivery complete!"

  Scenario: Handle incorrect odometer reading
  When I click "View Delivery"
    Then I should be on the delivery show page
    And I should see a "Quick Close" link for each shipment
    When I click "Quick Close" for a shipment
    And I accept the confirmation dialog
    Then I should be on the delivery show page
    And I should see a success message "Shipment successfully closed."
    And I wait for 5 seconds

    And I should see a "Mark Complete" button
    When I click "Mark Complete"
    Then I should see a confirmation modal
    When I click "Yes" in the confirmation modal
    Then I should see an odometer reading field
    When I enter "1" in the odometer reading field
    And I submit the completion form
    Then I should be on the delivery show page
    And I should see an error message "Odometer reading must be higher than previous value. Please revise."
