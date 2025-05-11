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
   - They navigate to the **Admin dashboard** via the top navigation bar.
   - Route: `/admin` (e.g., http://localhost:3000/admin)

2. **Initiate Maintenance**

   - On the Admin dashboard, each truck entry that has due maintenance includes a visible **orange `Maintenance` button**.
   - Clicking this button opens a **modal labeled `Maintenance Form`**.

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
- 🟡 Finds the orange Maintenance button visually out of sync with the rest of the UI
- 🔴 Frustrated that **only admins** can complete maintenance tasks—drivers are often more aware of the truck’s actual condition

---

## Pain Points

- **Role restrictions:** Only admin users can submit maintenance forms, limiting flexibility and slowing down operational workflows
- **UI inconsistency:** The orange Maintenance button doesn’t visually match the overall platform design

---

## Opportunities

- **XMDEV-347**: Allow drivers to fill out and submit maintenance forms, increasing accuracy and reducing admin overhead
- **XMDEV-348**: Implement email notifications for upcoming or overdue truck maintenance
- **XMDEV-349**: Update styling of the Maintenance button to align with platform design standards

---

## Outcome

The user successfully logged maintenance data into the system with no technical issues or errors. While the flow is generally efficient, enhancements to role permissions and visual design would improve the experience further.
