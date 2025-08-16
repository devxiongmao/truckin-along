Feature: Trucking Company Starting a Delivery
  As a driver of a trucking company
  I want to start my delivery
  So that my company and I can get paid

  @javascript
  Scenario: Driver starts a delivery
    Given I am logged in as a driver user with email "jane.smith@logico.com"
    Given I am on the deliveries start page
    When I click "Initiate" next to the "Volvo FH16" truck
    Then I should see a pre-delivery inspection modal
    When I check all required inspection checkboxes
    And I click "Confirm & Start Delivery"
    Then I should see a success message confirming the delivery was created
    And I should see the shipment map
    And I should be on the delivery show page
