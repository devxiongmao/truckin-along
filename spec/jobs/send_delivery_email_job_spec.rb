# spec/jobs/send_delivery_email_job_spec.rb
require 'rails_helper'

RSpec.describe SendDeliveryEmailJob, type: :job do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:shipment) { create(:shipment) }

  it 'enqueues the job with correct arguments' do
    expect {
      described_class.perform_later(user.id, shipment.id)
    }.to have_enqueued_job.with(user.id, shipment.id)
  end

  it 'calls the mailer with correct arguments and delivers the email' do
    mail_double = double("Mail", deliver_now: true)

    expect(ShipmentDeliveryMailer)
      .to receive(:successfully_delivered_email)
      .with(user.id, shipment.id)
      .and_return(mail_double)

    perform_enqueued_jobs do
      described_class.perform_later(user.id, shipment.id)
    end
  end
end
