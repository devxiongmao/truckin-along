# Custom test helpers for Cucumber scenarios
# This file contains setup that was moved from the generated env.rb file

# Include FactoryBot methods in Cucumber
World(FactoryBot::Syntax::Methods)

# Include Devise test helpers
include Warden::Test::Helpers
Warden.test_mode!

# Make sure Cucumber runs in the "test" environment
ENV['RAILS_ENV'] ||= 'test'

# Clean DB and load seeds before each scenario
Before do
  DatabaseCleaner.clean_with(:truncation)
  TestSeeds.load
end

Capybara.default_driver = :selenium
Capybara.javascript_driver = :selenium

