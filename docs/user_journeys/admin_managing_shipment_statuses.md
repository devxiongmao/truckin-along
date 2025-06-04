# User Journey: Admin Managing Shipment Statuses

## Persona

**Name:** Peter Parker, an admin user of a trucking company called Truckit.  
**Role:** Admin user  
**Goal:** Wants to create custom statuses unique to their company and set up an associated action

---

## Journey Overview

Each trucking company does things differently. They may have different steps or names for a given shipment status. Therefore, it's important that we give them the flexibility to configure it how they want.

---

## Steps

1. **Entry Point**

   - After login, the user navigates to the admin menu (available only for admins).
   - `/admin` route (http://localhost:3000/admin)

2. **Click the New Shipment Status Button**

   - User clicks a button that brings them to the new shipment status creation form.
   - Click a button, page changes to this route: `/shipment_statuses/new`

3. **Fill Out New Shipment Status Form**

   - User fills out the form. They need to have an idea of the shipment status name they'd like. This name is entered into the shipment status name field.
   - They also check off options depending on how they'd like shipments tied to this status to behave.
   - They must decide whether an associated shipment should be locked for customers (preventing edits) or fully closed (meaning no one can update it).

4. **Create the New Shipment Status**

   - Once the form is filled out, user hits the "Save Shipment Status" button.
   - User is redirected to the admin page (Step 1). A successful creation of a shipment status will result in a banner at the top of the screen confirming that the status was successfully created.
   - If errors occur, the user will be alerted and the form page will reload with all information preserved.

5. **Optional: Verification of New Shipment Status**

   - Upon successful creation, the admin can observe the new shipment status listed under the Statuses section.

6. **Click the Edit Button Tied to an Associated Shipment Action**

   - From the admin page, navigate to the `Manage Status Workflows` section.
   - The user decides which associated action they’d like to link to the new shipment status.
   - Click `Edit` beside that workflow action.

7. **Update the Shipment Status**

   - On the new page, update the shipment status dropdown.
   - Click `Update`.

8. **Verify Action Changed**

   - On the admin page, under the `Manage Status Workflows` section, the selected status is listed beside the associated action.
   - A visual confirmation banner appears at the top of the screen stating: `Preference was successfully updated.`

---

## Emotions

- 🟢 Easy creation of status
- 🟢 Shipment status automation—no additional manual work required
- 🟢 Users are pleased by the clear explainations of when the status change actions will be triggered within the app.

---

## Pain Points

- None currently reported in this workflow.

---

## Opportunities

- None currently reported in this workflow.

---

## Outcome

The user successfully created a unique shipment status for their company and paired it with an associated action in the shipping processing pipeline.
