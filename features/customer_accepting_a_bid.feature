Feature: Customer Managing Offers for a Shipment
  As a customer user
  I want to manage the offers for one of my shipments
  So that I can get the best offer while still delivering my shipment

  Background:
    Given I am logged in as a customer user
    And I am on the customer offers page

  Scenario: Customer rejects a bid offer
    Then I should see offers for shipment "Electronics Package"
    Then I should see 3 offers for shipment "Electronics Package"
    When I reject the offer from "SnapShip Solutions" for shipment "Electronics Package"
    And I should see a flash message "Offer was successfully rejected."
    And I should see 2 offers for shipment "Electronics Package"


  Scenario: Customer accepts a bid offer
    Then I should see offers for shipment "Electronics Package"
    When I accept the offer from "LogiCo Express" for shipment "Electronics Package"
    And I should see a flash message "Offer was successfully accepted. All other offers for this shipment have been rejected."