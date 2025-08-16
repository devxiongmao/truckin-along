Feature: Trucking Company Managing Truck Maintenance (Driver from Dashboard)
  As a driver of a trucking company
  I want to record maintenance for a truck from my dashboard
  So that our trucks are kept in service and compliant

  @javascript
  Scenario: Driver completes maintenance for a truck from the dashboard
    Given I am logged in as a driver user with email "jane.smith@logico.com"
    And I am on the root page
    When I click "TRUCKIN' ALONG"
    Then I should be redirected to the dashboard page
    When I click "Complete Maintenance" next to the "Dodge RAM" truck
    Then I should see a maintenance form modal
    And the modal should have fields for maintenance information

    When I fill in "Form Title" with "Oil and Tire Check"
    And I fill in "Date of completion" with "2024-01-15"
    And I fill in "Odometer Reading (e.g., 148723)" with "15000"
    And I check "Oil has been changed"
    And I check "Tire pressure has been checked"
    And I fill in "Additional Notes" with "Completed maintenance from dashboard"
    And I click "Confirm & Submit"
    Then I should see a confirmation message


