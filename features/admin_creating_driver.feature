Feature: Admin Creating a Driver
  As an admin user
  I want to create a new driver profile
  So that newly hired drivers can use Truckin' Along

  Background:
    Given I am logged in as an admin user
    And I am on the admin page

  Scenario: Successfully create a new driver with complete information
    Given I am on the admin page
    When I click "Create New Driver"
    Then I should be on the new driver creation form
    And I should see a form with fields for driver information

    When I fill in "First Name" with "Michael"
    And I fill in "Last Name" with "Holt"
    And I fill in "Driver's License" with "DL123456"
    And I fill in "Email" with "michael.holt@logico.com"
    And I click "Create Driver"
    Then I should be redirected to the admin page
    And I should see a success message confirming the driver was created
    And the new record, "Michael", should be listed under the "Drivers" section

  Scenario: Attempt to create driver with missing information
    Given I am on the admin page
    When I click "Create New Driver"
    Then I should be on the new driver creation form
    And I should see a form with fields for driver information

    When I fill in "First Name" with "Jane"
    And I fill in "Last Name" with "Smith"
    And I leave "Driver's License" empty
    And I fill in "Email" with "jane.smith@example.com"
    And I click "Create Driver"
    Then I should see an error message
    And I wait for 5 seconds
    And I should remain on the new driver creation form
    And the previously entered driver info should still be present

  Scenario: Create driver with placeholder information
    Given I am on the admin page
    When I click "Create New Driver"
    Then I should be on the new driver creation form
    And I should see a form with fields for driver information

    When I fill in "First Name" with "Bob"
    And I fill in "Last Name" with "Wilson"
    And I fill in "Driver's License" with "TBDTBDTB"
    And I fill in "Email" with "bob.wilson@example.com"
    And I click "Create Driver"
    Then I should be redirected to the admin page
    And I should see a success message confirming the driver was created
    And the new record, "Bob", should be listed under the "Drivers" section
    And the driver should have "TBD" as their license number

  Scenario: Navigate to driver creation from admin page
    Given I am on the admin page
    When I click "Create New Driver"
    Then I should be on the new driver creation form
    And the driver form should be empty and ready for input 