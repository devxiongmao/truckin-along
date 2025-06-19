require "rails_helper"

RSpec.describe TruckMailer, type: :mailer do
  describe ".send_truck_maintenance_due_email" do
    let(:user) { create(:user, role: "admin") }
    let!(:truck) { create(:truck, company: user.company) }
    let(:mail) { described_class.send_truck_maintenance_due_email(truck) }


    it "renders the headers" do
      expect(mail.subject).to eq("Truck Maintenance Due - #{truck.display_name}")
      expect(mail.to).to eq([ user.email ])
      expect(mail.from).to eq([ Rails.application.credentials.dig(:mailer, :default_from) || "from@example.com" ])
    end

    it "renders the body with the truck attributes" do
      expect(mail.body.encoded).to include(truck.make)
      expect(mail.body.encoded).to include(truck.model)
      expect(mail.body.encoded).to include(truck.year.to_s)
      expect(mail.body.encoded).to include(truck.license_plate)
      expect(mail.body.encoded).to include(truck.vin)
      expect(mail.body.encoded).to include(truck.mileage.to_s)
      expect(mail.body.encoded).to include(truck.weight.to_s)
    end
  end
end
