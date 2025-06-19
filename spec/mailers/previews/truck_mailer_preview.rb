# Preview all emails at http://localhost:3000/rails/mailers/truck_mailer_mailer
class TruckMailerPreview < ActionMailer::Preview
  def send_truck_maintenance_due_email
    truck = FactoryBot.create(:truck)
    TruckMailer.send_truck_maintenance_due_email(truck)
  end
end
