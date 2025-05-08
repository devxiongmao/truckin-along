# spec/mailers/shipment_delivery_mailer_spec.rb
require "rails_helper"

RSpec.describe ShipmentDeliveryMailer, type: :mailer do
  describe '#successfully_delivered_email' do
    let(:user) { create(:user, role: "customer") }
    let(:shipment) { create(:shipment, user: user) }

    let(:mail) { described_class.successfully_delivered_email(shipment.id) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Your package has been delivered!')
      expect(mail.to).to eq([ user.email ])
      expect(mail.from).to eq([ 'no-reply@example.com' ])
    end

    it 'assigns the user and shipment properly' do
      expect(mail.body.encoded).to include(user.display_name)
      expect(mail.body.encoded).to include(shipment.name)
    end
  end
end
