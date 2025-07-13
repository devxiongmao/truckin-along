Feature: Admin Creating a Truck
  As an admin user
  I want to create a new truck profile
  So that newly acquired vehicles can be used for deliveries

  Background:
    Given I am logged in as an admin user
    And I am on the admin page

  Scenario: Successfully create a new truck with complete information
    Given I am on the admin page
    When I click "New Truck"
    Then I should be on the new truck creation form
    And I should see a form with fields for truck information

    When I fill in "Make" with "Ford"
    And I fill in "Model" with "F-150"
    And I fill in "Year" with "2023"
    And I fill in "Mileage" with "15000"
    And I fill in "VIN #" with "1FADP3F22ML123456"
    And I fill in "License Plate" with "ABC123"
    And I fill in "Haul Weight (kg)" with "1000"
    And I fill in "Length of Bed (cm)" with "200"
    And I fill in "Width of Bed (cm)" with "150"
    And I fill in "Height of Bed (cm)" with "50"
    And I click "Save Truck"
    Then I should be redirected to the admin page
    And I should see a success message confirming the truck was created
    And the new truck, "Ford F-150", should be listed under the "Trucks" section

  Scenario: Attempt to create truck with missing information
    Given I am on the admin page
    When I click "New Truck"
    Then I should be on the new truck creation form
    And I should see a form with fields for truck information

    When I fill in "Make" with "Chevrolet"
    And I fill in "Model" with "Silverado"
    And I fill in "Year" with "2022"
    And I leave "VIN #" empty
    And I fill in "License Plate" with "XYZ789"
    And I fill in "Haul Weight (kg)" with "1200"
    And I click "Save Truck"
    Then I should see an error message
    And I should remain on the new truck creation form
    And the previously entered information should still be present

  Scenario: Create truck with placeholder information
    Given I am on the admin page
    When I click "New Truck"
    Then I should be on the new truck creation form
    And I should see a form with fields for truck information

    When I fill in "Make" with "Dodge"
    And I fill in "Model" with "Ram"
    And I fill in "Year" with "2024"
    And I fill in "Mileage" with "5000"
    And I fill in "VIN #" with "TBDTBDTBD"
    And I fill in "License Plate" with "TBD"
    And I fill in "Haul Weight (kg)" with "1100"
    And I fill in "Length of Bed (cm)" with "180"
    And I fill in "Width of Bed (cm)" with "140"
    And I fill in "Height of Bed (cm)" with "45"
    And I click "Save Truck"
    Then I should be redirected to the admin page
    And I should see a success message confirming the truck was created
    And the new truck, "Dodge Ram", should be listed under the "Trucks" section
    And the truck should have "TBD" as its VIN number

  Scenario: Complete initial maintenance for newly created truck
    Given I am on the admin page
    And a truck "Ford F-150" exists in the system
    When I click "Maintenance" next to the "Ford F-150" truck
    Then I should see a maintenance form modal
    And the modal should have fields for maintenance information

    When I fill in "Maintenance Title" with "Initial Setup"
    And I fill in "Date of Completion" with "2024-01-15"
    And I fill in "Current Mileage" with "15000"
    And I check "Oil Change"
    And I check "Tire Pressure Check"
    And I fill in "Notes" with "Initial maintenance completed"
    And I click "Confirm and Submit"
    Then the maintenance should be successfully recorded
    And I should see a confirmation message

  Scenario: Navigate to truck creation from admin page
    Given I am on the admin page
    When I click "New Truck"
    Then I should be on the new truck creation form
    And the form should be empty and ready for input
