class TruckMailer < ApplicationMailer
  def send_truck_maintenance_due_email(truck_id)
    @truck = Truck.find(truck_id)
    mail(to: @truck.company.admin_emails, subject: "Truck Maintenance Due - #{@truck.display_name}")
  end
end
