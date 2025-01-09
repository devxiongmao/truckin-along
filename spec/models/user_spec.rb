require 'rails_helper'

RSpec.describe User, type: :model do
  # Define a valid user object for reuse
  let(:valid_user) do
    User.new(
      email: "test@example.com",
      password: "password",
      role: "admin" # Default role for testing
    )
  end

  ## Validation Tests
  describe "validations" do
    subject { valid_user } # Use a valid user as the baseline for testing

    # Presence Validations
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }

    # Email Format Validation
    it "is invalid with an incorrectly formatted email" do
      valid_user.email = "invalid_email"
      expect(valid_user).not_to be_valid
    end

    # Password Length Validation
    it "is invalid with a password shorter than 6 characters" do
      valid_user.password = "12345"
      expect(valid_user).not_to be_valid
    end

    it "is valid with a password of 6 or more characters" do
      valid_user.password = "123456"
      expect(valid_user).to be_valid
    end
  end

  ## Role Tests
  describe "roles" do
    it "is valid with a role of admin" do
      valid_user.role = "admin"
      expect(valid_user).to be_valid
    end

    it "is valid with a role of driver" do
      valid_user.role = "driver"
      expect(valid_user).to be_valid
    end

    it "is invalid with an undefined role" do
      valid_user.role = "manager"
      expect(valid_user).not_to be_valid
    end
  end

  ## Admin Method Tests
  describe "#admin?" do
    it "returns true if the user's role is admin" do
      valid_user.role = "admin"
      expect(valid_user.admin?).to eq(true)
    end

    it "returns false if the user's role is driver" do
      valid_user.role = "driver"
      expect(valid_user.admin?).to eq(false)
    end
  end

  ## Valid User Test
  describe "valid user" do
    it "is valid with all required attributes" do
      expect(valid_user).to be_valid
    end
  end

  ## Invalid User Tests
  describe "invalid user" do
    it "is invalid without an email" do
      valid_user.email = nil
      expect(valid_user).not_to be_valid
    end

    it "is invalid without a password" do
      valid_user.password = nil
      expect(valid_user).not_to be_valid
    end

    it "is invalid with a blank role" do
      valid_user.role = nil
      expect(valid_user).not_to be_valid
    end
  end
end
