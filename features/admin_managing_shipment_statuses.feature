Feature: Admin Managing Shipment Statuses
  As an admin user
  I want to manage a shipment status
  So that I can effectively manage shipments for my company

  Background:
    Given I am logged in as an admin user
    And I am on the admin page
    And seed data is loaded

  Scenario: Successfully create a new shipment status
    Given I am on the admin page
    When I click "New Shipment Status"
    Then I should be on the new shipment status creation form
    And I should see a form with fields for shipment status information

    When I fill in "Name" with "Processing"
    And I check "Mark as Closed?"
    And I click "Save Shipment Status"
    Then I should be redirected to the admin page
    And I should see a success message confirming the shipment status was created
    And the new record, "Processing", should be listed under the "Shipment Statuses" section

  Scenario: Assign Shipment Status to Common Action 
    Given I am on the admin page
    When I click "Edit" in the row that contains "Claimed by company"
    Then I should be on the shipment action preference form page

    When I fill in "Name" with "Processing"
    And I click "Update"
    Then I should be redirected to the admin page
    And I should see a success message confirming the shipment action preference was saved
    And the text, "Claimed by company", should be in the row next the text, "Processing"