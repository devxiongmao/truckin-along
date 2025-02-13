require 'rails_helper'

RSpec.describe "User Authentication", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)
  end

  it "allows a user to sign in" do
    visit new_user_session_path

    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    expect(page).to have_content("Signed in successfully")
    expect(page).to have_current_path(root_path) 
  end

  it "rejects invalid credentials" do
    visit new_user_session_path

    fill_in "Email", with: "wrong@example.com"
    fill_in "Password", with: "incorrectpassword"
    click_button "Log in"

    expect(page).to have_content("Invalid Email or password")
  end

  it "allows a user to sign out" do
    sign_in user 
    visit root_path

    click_link "Sign Out" 

    expect(page).to have_content("Signed out successfully")
    expect(page).to have_current_path(root_path)
  end
end
