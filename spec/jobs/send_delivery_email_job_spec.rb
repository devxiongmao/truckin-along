# spec/jobs/send_delivery_email_job_spec.rb
require 'rails_helper'

RSpec.describe SendDeliveryEmailJob, type: :job do
  include ActiveJob::TestHelper

  let(:shipment) { create(:shipment) }

  it 'enqueues the job with correct arguments' do
    expect {
      described_class.perform_later(shipment.id)
    }.to have_enqueued_job.with(shipment.id)
  end

  it 'calls the mailer with correct arguments and delivers the email' do
    mail_double = double("Mail", deliver_now: true)

    expect(ShipmentDeliveryMailer)
      .to receive(:successfully_delivered_email)
      .with(shipment.id)
      .and_return(mail_double)

    perform_enqueued_jobs do
      described_class.perform_later(shipment.id)
    end
  end
end
