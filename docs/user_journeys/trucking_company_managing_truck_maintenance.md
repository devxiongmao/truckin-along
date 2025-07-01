# User Journey: Trucking Company Managing Truck Maintenance

## Persona

**Name:** Peter Parker  
**Role:** Driver or admin affiliated with a trucking company using the Truckin' Along platform  
**Goal:** Record and manage maintenance information for a truck in the company’s fleet

---

## Journey Overview

As trucks rack up mileage and time on the road, regular maintenance becomes critical for performance, safety, and regulatory compliance. Users—typically admins, but ideally also drivers—are responsible for logging this maintenance in the system. This journey describes how a user is notified of upcoming or due maintenance, fills out the necessary form, and links that data to the truck’s record.

---

## Steps

1. **Entry Point**

   - The user receives an **email notification** alerting them that a truck in their fleet is due for maintenance.
   - They navigate to the **Admin dashboard** via the top navigation bar or the main dashboard page
   - Route: `/admin` (e.g., http://localhost:3000/admin) or `/dashboard` (e.g., http://localhost:3000/dashboard)

2. **Initiate Maintenance**

   - On the Admin dashboard, each truck entry that has due maintenance includes a visible **orange `Maintenance` button**.
   - Clicking this button opens a **modal labeled `Maintenance Form`**.
   - Alternatively, on the Dashboard page, Drivers will see this same view and can complete the maintenance for the trucks.

3. **Fill Out the Maintenance Form**

   - Within the modal, the user is prompted to complete the following fields:
     - **Maintenance Title**
     - **Date of Completion**
     - **Current Mileage**
     - **Checkboxes** confirming:
       - Oil Change
       - Tire Pressure Check
     - **Optional Notes** field for additional comments

4. **Submit the Maintenance Form**

   - After completing the form, the user clicks **`Confirm and Submit`**.
   - On success:
     - Maintenance data is saved and linked to the truck’s record.
     - The modal closes and the user returns to the Admin dashboard.
   - On failure:
     - An error message is displayed, and the form data is retained for correction.

---

## Emotions

- 🟢 Relieved and satisfied that the app proactively notified them of due maintenance
- 🟢 Grateful for the quick, low-effort maintenance form process
- 🟢 Grateful for the email notifications alerting for due truck maintenance

---

## Pain Points

- None currently reported in this workflow

---

## Opportunities

- None currently reported in this workflow

---

## Outcome

The user successfully logged maintenance data into the system with no technical issues or errors. While the flow is generally efficient, enhancements to role permissions would improve the experience further.
