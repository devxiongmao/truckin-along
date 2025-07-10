require 'rails_helper'

RSpec.describe User, type: :model do
  # Define a valid user object for reuse
  let(:valid_user) { create(:user, :driver) }
  let(:valid_driver) { build(:user, role: "driver", drivers_license: "AB123456") }
  let(:valid_admin) { build(:user, role: "admin", drivers_license: "CD789012") }
  let(:valid_customer) { build(:user, role: "customer", drivers_license: nil) }

  ## Association Tests
  describe "associations" do
    it { is_expected.to have_many(:shipments) }
    it { is_expected.to have_many(:deliveries).dependent(:nullify) }
    it { is_expected.to have_many(:forms).dependent(:nullify) }
    it { should belong_to(:company).optional }
    it { is_expected.to have_many(:ratings).dependent(:destroy) }
  end

  ## Association Tests
  describe "associations" do
    it { is_expected.to have_many(:shipments) }
    it { should belong_to(:company).optional }
  end

  ## Validation Tests
  describe "validations" do
    context "when user is a driver or admin" do
      it { is_expected.to validate_presence_of(:drivers_license) }
      it { is_expected.to validate_uniqueness_of(:drivers_license) }
      it { is_expected.to validate_length_of(:drivers_license).is_equal_to(8) }

      it "is valid with a properly formatted drivers_license" do
        expect(valid_driver).to be_valid
        expect(valid_admin).to be_valid
      end

      it "is invalid with an incorrectly formatted drivers_license" do
        invalid_user = build(:user, role: "driver", drivers_license: "abc123")
        expect(invalid_user).not_to be_valid
      end

      it "is invalid without a drivers_license" do
        invalid_user = build(:user, role: "driver", drivers_license: nil)
        expect(invalid_user).not_to be_valid
      end
    end

    context "when user is a customer" do
      it "is valid without a drivers_license" do
        expect(valid_customer).to be_valid
      end
    end

    # Presence Validations
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }

    # Email Format Validation
    it "is invalid with an incorrectly formatted email" do
      valid_driver.email = "invalid_email"
      expect(valid_driver).not_to be_valid
    end

    # Password Length Validation
    it "is invalid with a password shorter than 6 characters" do
      valid_driver.password = "12345"
      expect(valid_driver).not_to be_valid
    end

    it "is valid with a password of 6 or more characters" do
      valid_driver.password = "123456"
      valid_driver.password_confirmation = "123456"
      expect(valid_driver).to be_valid
    end

    it "is valid with a blank home_address" do
      valid_driver.home_address = ""
      expect(valid_driver).to be_valid
    end

    it "is valid when home_address is within 255 characters" do
      valid_driver.home_address = "A" * 255
      expect(valid_driver).to be_valid
    end

    it "is invalid when home_address exceeds 255 characters" do
      valid_driver.home_address = "A" * 256
      expect(valid_driver).not_to be_valid
      expect(valid_driver.errors[:home_address]).to include("is too long (maximum is 255 characters)")
    end
  end

  ## Enum Tests
  describe "roles" do
    it "allows valid roles" do
      valid_user.role = :driver
      expect(valid_user).to be_valid

      valid_user.role = :admin
      expect(valid_user).to be_valid

      valid_user.role = :customer
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
    let! (:company) { create(:company) }
    let!(:driver_user) { create(:user, email: "driver@example.com", role: "driver", company: company) }
    let!(:admin_user) { create(:user, email: "admin@example.com", role: "admin", company: nil) }

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

    describe ".for_company" do
      it "includes users who belong to the company" do
        expect(User.for_company(company)).to include(driver_user)
        expect(User.for_company(company)).not_to include(admin_user)
      end
    end
  end

  ## Custom Method Tests
  describe "#display_name" do
    it "returns the users display name" do
      expect(valid_user.display_name).to eq("John Doe")
    end

    it "handles nil values gracefully" do
      valid_user.first_name = nil
      valid_user.last_name = nil
      expect(valid_user.display_name).to eq(" ")
    end
  end

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

  describe "#driver?" do
    it "returns true if the user's role is driver" do
      valid_user.role = :driver
      expect(valid_user.driver?).to eq(true)
    end

    it "returns false if the user's role is admin" do
      valid_user.role = :admin
      expect(valid_user.driver?).to eq(false)
    end
  end

  describe "#customer?" do
    it "returns true if the user's role is customer" do
      valid_user.role = :customer
      expect(valid_user.customer?).to eq(true)
    end

    it "returns false if the user's role is anything else" do
      valid_user.role = :admin
      expect(valid_user.driver?).to eq(false)
    end
  end

  describe "#has_company?" do
    let(:company) { create(:company) }
    it "returns true if the user's company is set" do
      valid_user.company = company
      expect(valid_user.has_company?).to eq(true)
    end

    it "returns false if the user's company not set" do
      valid_user.company = nil
      expect(valid_user.has_company?).to eq(false)
    end
  end

  describe "#available?" do
    describe "when there is an active delivery" do
      let!(:delivery) { create(:delivery, user: valid_user) }
      it "returns false" do
        expect(valid_user.available?).to eq(false)
      end
    end

    describe "when there is not an active delivery" do
      it "returns true" do
        expect(valid_user.available?).to eq(true)
      end
    end
  end

  describe "#active_delivery" do
    describe "when there is an active delivery" do
      let!(:delivery) { create(:delivery, user: valid_user) }
      it "returns the delivery" do
        expect(valid_user.active_delivery).to eq(delivery)
      end
    end

    describe "when there is not an active delivery" do
      it "returns nil" do
        expect(valid_user.active_delivery).to be_nil
      end
    end
  end
end
