Feature: Admin Creating a Driver
  As a user
  I want to sign up as a customer
  So I can use the features of Truckin' Along

  Background:
    Given I am on the root page

  Scenario: Successfully create a new driver with complete information
    Given I am on the root page
    When I click "Sign Up as Customer"
    Then I should be on the new user creation form
    And I should see a form with fields for user creation

    When I fill in "First Name" with "Michael"
    And I fill in "Last Name" with "Holt"
    And I fill in "Home address" with "Ray Twinney Court, Newmarket, Ontario, Canada"
    And I fill in "Email" with "michael.holt@logico.com"
    And I fill in "Password" with "password123"
    And I fill in "Confirm Password" with "password123"
    And I click "Sign up"
    Then I should be redirected to the dashboard page
    And I should see a success message confirming the user was created
