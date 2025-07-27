# Custom test helpers for Cucumber scenarios
# This file contains setup that was moved from the generated env.rb file

# Include FactoryBot methods in Cucumber
World(FactoryBot::Syntax::Methods)

# Include Devise test helpers
include Warden::Test::Helpers
Warden.test_mode!


# Capybara.default_driver = :selenium
