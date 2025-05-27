require "rails_helper"

RSpec.describe DriverMailer, type: :mailer do
  describe ".send_temp_password" do
    let(:user) { create(:user, email: "test@example.com", first_name: "Bobby", last_name: "B") }
    let(:temp_password) { "Abcd1234!@#" }
    let(:mail) { described_class.send_temp_password(user, temp_password) }

    it "renders the headers" do
      expect(mail.subject).to eq("Your Account Has Been Created")
      expect(mail.to).to eq([ "test@example.com" ])
      expect(mail.from).to eq([ Rails.application.credentials.dig(:mailer, :default_from) || "from@example.com" ])
    end

    it "renders the body with the user's name" do
      expect(mail.body.encoded).to include("Hello Bobby B")
    end

    it "includes the temporary password in the email body" do
      expect(mail.body.encoded).to include(temp_password)
    end

    it "encourages the user to change their password" do
      expect(mail.body.encoded).to include("Please change your password after logging in")
    end
  end
end
