require 'rails_helper'

RSpec.describe User, type: :model do
  # Define a valid user object for reuse
  let(:valid_user) do
    User.new(
      email: "test@example.com",
      password: "password",
      role: :driver
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

  ## Enum Tests
  describe "roles" do
    it "allows valid roles" do
      valid_user.role = :driver
      expect(valid_user).to be_valid

      valid_user.role = :admin
      expect(valid_user).to be_valid
    end

    it "does not allow invalid roles" do
      expect { valid_user.role = :manager }.to raise_error(ArgumentError)
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
  end

  ## Scope Tests
  describe "scopes" do
    let!(:driver_user) { User.create!(email: "driver@example.com", password: "password", role: :driver) }
    let!(:admin_user) { User.create!(email: "admin@example.com", password: "password", role: :admin) }
  
    describe ".drivers" do
      it "includes only users with the driver role" do
        expect(User.drivers).to include(driver_user)
        expect(User.drivers).not_to include(admin_user)
      end
    end

    describe ".admins" do
      it "includes only users with the admin role" do
        expect(User.admins).to include(admin_user)
        expect(User.admins).not_to include(driver_user)
      end
    end
  end

  ## Custom Method Tests
  describe "#admin?" do
    it "returns true if the user's role is admin" do
      valid_user.role = :admin
      expect(valid_user.admin?).to eq(true)
    end

    it "returns false if the user's role is driver" do
      valid_user.role = :driver
      expect(valid_user.admin?).to eq(false)
    end
  end
end
