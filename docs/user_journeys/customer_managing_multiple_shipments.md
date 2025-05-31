# User Journey: Customer Creating a Shipment

## Persona

**Name:** John Doe, a person matching our standard customer profile  
**Role:** Customer  
**Goal:** Create and ship a shipment through Truckin' Along

---

## Journey Overview

This user is here because they want to use Truckin' Along’s services to get multiple shipments delivered. They're looking for cheaper shipping.

---

## Steps

1. **Entry Point**

   - After logging in, the user navigates to the Shipments menu.
   - Route: `/shipments` (http://localhost:3000/shipments)

2. **Click the New Shipment Button**

   - User clicks the "New Shipment" button to begin the creation process.
   - Route changes to: `/shipments/new`

3. **Fill Out the New Shipment Form**

   - User fills out the form, which requires:
     - Shipment name
     - Recipient name
     - Recipient address
     - Weight
     - Length, height, and width
   - The sender’s name and address are pre-populated but editable.
   - If the user doesn't have all necessary information, they will need to return to this step later.

4. **Create the New Shipment**

   - Once the form is complete, the user clicks the "Save Shipment" button.
   - User is redirected to the shipment show page: `/shipments/:id`
   - A banner at the top confirms successful creation.
   - If there are validation errors, the form reloads with all data preserved and an error alert is shown.

5. **Verification**

   - On the show page, a map displays the shipment’s straight-line travel distance.
   - This provides a visual cue to confirm the entered data is accurate.
   - The user may click the `Edit Shipment` button if changes are needed.

6. **Optional: Create Additional Shipments → Click the Back to Index Button**

   - If the user has more packages to send (e.g., similar in size or weight), they click the `Back to Index` button to return to the shipment list.

7. **Optional: Duplicate the Shipment → Click the Copy Button**

   - In the shipment list, the user finds their newly created shipment and clicks the `Copy` button beside it.
   - This leads to the shipment copy page: `/shipments/:id/copy`
   - The user returns to Step 3 and can repeat Steps 3–5 as many times as needed.

8. **Outcome**

   - Back on the `/shipments` page, the user can now view all of their created shipments.

---

## Emotions

- 🟢 Pleased with the short, simple form
- 🟡 Slight friction: two clicks required to begin creating a shipment after login
- 🔴 Confusion around how to duplicate shipments

---

## Pain Points

- The process for duplicating shipments isn’t intuitive or clearly explained.

---

## Opportunities

- Add a direct "Create New Shipment" button to the top of the dashboard page to reduce clicks. (XMDEV-338)
- The `Delete Shipment` button should not always be visible. (XMDEV-336)
- Add a `Copy` button to the shipment show page. (XMDEV-337)

---

## Outcome

The user successfully created a shipment and was able to duplicate it as needed. This allowed trucking companies to claim and process the shipment efficiently.
