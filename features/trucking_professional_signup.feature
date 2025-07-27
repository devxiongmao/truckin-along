Feature: Admin Creating a Driver
  As a user
  I want to sign up as a trucking admin
  So I can use the features of Truckin' Along

  Background:
    Given I am on the root page

  Scenario: Successfully create a new trucking admin with complete information
    Given I am on the root page
    When I click "Sign Up as Trucking Professional"
    Then I should be on the new admin creation form
    And I should see a form with fields for admin creation

    When I fill in "First Name" with "Clark"
    And I fill in "Last Name" with "Kent"
    And I fill in "Home address" with "Ray Twinney Court, Newmarket, Ontario, Canada"
    And I fill in "Email" with "clark.kent@logico.com"
    And I fill in "Driver's License" with "DL123456"
    And I fill in "Password" with "password123"
    And I fill in "Confirm Password" with "password123"
    And I click "Sign up"
    Then I should be on the company creation page
    And I should see a form with fields for the new company
    
    When I fill in "Company Name" with "Logico"
    And I fill in "Company Address" with "101 Beep Beep Way, Toronto, Ontario, Canada"
    And I fill in "Company Phone Number" with "647-888-8888"
    And I click "Create Company"
    Then I should be redirected to the dashboard page
    Then I should see a success message confirming the company was created


