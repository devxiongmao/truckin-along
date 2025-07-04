# User Journey: Driver Setting a Delivery to Be Closed

## Persona

**Name:** Peter Parker  
**Role:** A registered driver currently on a delivery using the Truckin' Along platform  
**Goal:** To mark a shipment as delivered (i.e., close the shipment)

---

## Journey Overview

As Peter completes the physical delivery of packages to their destination, he must mark those shipments as "delivered" in the system. The platform supports two methods of closing shipments: a quick close workflow (if configured by the company) and a manual update workflow. This journey outlines both options.

---

## Steps

1. **Entry Point: Accessing the Start Deliveries Page**

   - The user navigates to the **Start Deliveries** page from the top navigation bar
   - Route: `/deliveries/start`
   - Example: `http://localhost:3000/deliveries/start`

2. **View the Active Delivery**

   - From the list of active deliveries, the user clicks the **`View Delivery`** button for the delivery in progress
   - Route: `/deliveries/:id`
   - Example: `http://localhost:3000/deliveries/1`

3. **Option A: Quick Close a Shipment**

   - On the Delivery Show page, each shipment has `Show` and `Quick Close` buttons
   - If **Quick Close** is enabled by the company, clicking it will:
     - Open a browser alert asking to confirm the delivery
     - Options: `Cancel` or `OK`
     - If `OK` is clicked, the shipment is marked as closed

4. **Option B: Manually Close via Shipment Edit**

   - If Quick Close is **not configured**, the user must:
     - Click `Edit` next to the desired shipment (navigates to `/shipments/:id/edit`)
     - In the edit view, update the **Shipment Status** field to `Delivered` or the appropriate final status
     - Submit the form to apply changes

5. **Confirmation and Feedback**

   - If closed via **Quick Close**:

     - Redirect to the Delivery Show page
     - Banner appears: `Shipment successfully closed.`

   - If closed via **Manual Edit**:
     - Redirect to the Shipment Show page
     - Banner appears: `Shipment was successfully updated.`

---

## Emotions

- 🟢 Pleased when Quick Close is available — fast and efficient
- 🟢 Please with power behind manual process - able to manipulate all fields quickly

---

## Pain Points

- None currently reported in this workflow

---

## Opportunities

- None currently reported in this workflow

---

## Outcome

At the end of this journey, the user successfully marked shipments as delivered, either via the streamlined **Quick Close** method or through the more detailed **manual update** process.
