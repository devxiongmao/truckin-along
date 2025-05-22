# User Journey: Admin Managing Shipment Statuses

## Persona

**Name:** Peter Parker, an admin user of a trucking company signed up called Truckit.
**Role:** Admin user
**Goal:** Wants to create custom statuses unique to their company and set up an associated action

---

## Journey Overview

Each trucking company does things differently. They may have different steps, or names for a given shipment status. Therefore, it's important that we give them that flexibility to configure it how they want.

---

## Steps

1. **Entry Point**

   - After login, user navigates to the admin menu (solely available for admins)
   - /admin route (http://localhost:3000/admin)

2. **Click the New Shipment Status Button**

   - User clicks a button which brings them to the new shipment status creation form
   - Click a button, page changes to this route: /shipment_statuses/new

3. **Fill Out New Shipment Status Form**

   - User needs to fill out the form. They need to have an idea of what shipment status name they'd like. They put the shipment status within the shipment status name field
   - They also check off checkboxes depending on how they'd like shipments tied to this status to behave. They'll need to decide if an associated shipment should be locked for customers, meaning customers can make no further edits, or if it's fully closed. Meaning that no one can update the shipment.

4. **Create the New Shipment Status**

   - Once form is filled out, user hits "Save Shipment Status" button.
   - Click a button, and user is redirected to the admin page (step 1). A successful creation of a shipment statys will result in a banner at the top of the screen showing confirming the status was successfully created.
   - If errors occur, user will be alerted and form page will be reloaded with all information.

5. **Optional: Verification of New Shipment Status**

   - Upon successful creation, Admin can observe the new shipment status created under the statuses section.

6. **Click the Edit Button Tied to an Associated Shipment Action**

   - From the admin page, navigate down to the `Manage Status Workflows` section.
   - The user should decide which associated action they'd like to associated the shipment status to.
   - Click `Edit` beside that workflow action

7. **Update the Shipment Status**

   - On this new page, update the shipment status dropdown
   - Click `Update`

8. **Verify Action Changed**
   - On the admin page, under the `Manage Status Workflows` section, the selected status is listed beside the associated action along with a visual banner inspection at the top confirming that the `Preference was successfully updated.`.

---

## Emotions

- 🟢 Easy creation of status
- 🟢 Shipment status automation. No additional manual work required
- 🟡 Confusion around when a particular workflow might apply.

---

## Pain Points

- User may not know when the associated action is triggered within the app.

---

## Opportunities

- Update the copy on the workflow action page to explain when a given action is triggered within the app.

---

## Outcome

This user, through this journey was able to craft a unique shipment status to their company, and pair it with an associated action present within a shipping processing pipeline.
