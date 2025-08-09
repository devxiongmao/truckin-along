Feature: Customer Creating a Shipment
  As a customer user
  I want to create a new shipment
  So that this shipment can be delivered via the platform

  Background:
    Given I am logged in as a customer user
    And I am on the customer shipment page

  Scenario: Successfully create a new shipment with complete information
    Given I am on the customer shipment page
    When I click "New Shipment"
    Then I should be on the new shipment creation form
    And I should see a form with fields for shipment information

    When I fill in "Name" with "Documents"
    And I fill in "Sender name" with "Peter Parker"
    And I fill in "Sender address" with "101 Tech Blvd, Silicon Valley, USA"
    And I fill in "Receiver name" with "Clark Kent"
    And I fill in "Receiver address" with "123 Main St, Anytown, USA"
    And I fill in "Weight (kg)" with "1"
    And I fill in "Length (cm)" with "20"
    And I fill in "Width (cm)" with "30"
    And I fill in "Height (cm)" with "1"
    And I set the "Deliver By" date field to 5 days from today

    And I click "Save Shipment"
    Then I should be redirected to the shipment show page
    And I should see a success message confirming the shipment was created

  Scenario: Attempt to create shipment with missing information
    Given I am on the customer shipment page
    When I click "New Shipment"
    Then I should be on the new shipment creation form
    And I should see a form with fields for shipment information

    When I fill in "Name" with "Documents"
    And I fill in "Sender name" with "Peter Parker"
    And I fill in "Sender address" with "101 Tech Blvd, Silicon Valley, USA"
    And I fill in "Receiver name" with "Clark Kent"
    And I fill in "Receiver address" with "123 Main St, Anytown, USA"
    And I fill in "Weight (kg)" with "1"
    And I click "Save Shipment"
    Then I should see an error message
    And I should remain on the new shipment creation form
    And the previously entered shipment information should still be present