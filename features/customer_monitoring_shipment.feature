Feature: Customer Monitoring a Shipment
  As a customer user
  I want to check the status of one of my shipments
  So that I can track the progress of where this shipment is while being delivered

  Background:
    Given I am logged in as a customer user
    And I am on the customer shipment page

  Scenario: Successfully check on a shipment
    Given I am on the customer shipment page
    And I click the "Show" link for shipment "Documents"
    Then I should see the shipment map
    And I should see a "Rate" button
    And I should see a "LogiCo Express" link