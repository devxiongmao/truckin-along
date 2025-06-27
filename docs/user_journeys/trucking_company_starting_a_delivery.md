# User Journey: Trucking Company Starting a Delivery

## Persona

**Name:** Peter Parker  
**Role:** Driver or admin associated with a trucking company using the Truckin' Along platform  
**Goal:** To kick off a delivery route for a fully loaded truck

---

## Journey Overview

Once trucks have been successfully loaded with shipments, the next step in the delivery workflow is to **initiate the delivery process**. This includes reviewing available trucks, completing a regulatory pre-inspection checklist, and formally starting the delivery. This journey ensures both **compliance** and **logistical readiness** for getting shipments on the road.

---

## Steps

1. **Entry Point: Accessing the Start Delivery Page**

   - The user navigates to the **Start Deliveries** page from the top navigation bar
   - Route: `/deliveries/start` (e.g., http://localhost:3000/deliveries/start)

2. **Review Available Trucks**

   - This page displays **trucks not currently on active deliveries**
   - Each truck card includes:
     - Earliest scheduled shipment delivery time
     - Volume and weight metrics
   - Users can optionally click the `Delivery` button to view the **Delivery Show** page, which includes a map and more route details
   - After reviewing, users can return to the Start Deliveries page via the back button

3. **Initiate the Delivery**

   - Once a truck is selected, the user clicks the **`Initiate`** button beside the desired truck
   - This opens a modal titled **Pre-Delivery Inspection Checklist**

4. **Complete the Pre-Delivery Inspection**

   - The user performs a **physical truck inspection** and logs findings via a checklist in the modal
   - Every required checkbox must be checked to enable submission
   - The user completes the form and clicks **`Confirm and Start Delivery`**
   - If the form is incomplete, missing sections are highlighted and submission is blocked

5. **Confirmation: Delivery In Progress**

   - If submission is successful:
     - The user is redirected to the **Delivery Show** page
     - A banner confirms: `Delivery was successfully created with X shipments.`
   - The delivery is now marked as active and in progress

---

## Emotions

- 🟢 Satisfied with the overall simplicity of the start procedure
- 🟢 Satisfied with the check sections buttons to complete the inspection form faster

---

## Pain Points

- None currently reported in this workflow

---

## Opportunities

- **XMDEV-356**: Update deliveries start page to show earliest scheduled shipment delivery time
- **XMDEV-354**: Add map to the Delivery Show page for better spatial awarenessform

---

## Outcome

The user successfully initiated a delivery while ensuring all **regulatory pre-inspection requirements** were fulfilled. They were able to review trucks, inspect them, and launch the route without errors or confusion. The journey was efficient, and users appreciate the ability to quickly fill out the pre-delivery from.
