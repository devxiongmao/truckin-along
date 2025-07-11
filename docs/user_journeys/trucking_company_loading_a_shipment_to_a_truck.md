# User Journey: Trucking Company Loading a Shipment to a Truck

## Persona

**Name:** Peter Parker  
**Role:** Driver or admin associated with a trucking company using the Truckin' Along platform  
**Goal:** Assign a shipment to an appropriate truck, optimizing for route efficiency and delivery grouping

---

## Journey Overview

Once a shipment has been claimed by a trucking company, the next step is deciding **which truck** should carry it. This workflow allows the user to group multiple shipments by delivery location and route, increasing operational efficiency and reducing costs. This journey focuses on assigning a shipment to the most appropriate truck based on planned stops and geography.

---

## Steps

1. **Entry Point**

   - The user navigates to the **Truck Loading** page via the top navigation bar
   - Route: `/deliveries/load_truck` (e.g., http://localhost:3000/deliveries/load_truck)

2. **Review Available Trucks**

   - The top of the page features a **visual map** displaying:
     - Active trucks
     - Their current routes and planned stops
   - This view helps users understand truck paths at a glance

3. **Analyze Shipment Alignment**

   - When the user **hovers over a shipment**, the system temporarily renders the **dropoff location** on the map
   - Users can compare this dropoff location to current truck routes to identify the most optimal pairing

4. **Assign Shipment to Truck**

   - The user selects:
     - A shipment (via checkbox)
     - A truck (via dropdown selector)
   - Then clicks the **`Add to Truck`** button

5. **Confirmation and Feedback**

   - On success:
     - A **green banner** appears: `Shipments successfully assigned to truck`
     - The user is redirected back to Step 1 for continued workflow
   - On failure:
     - A **red banner** appears with relevant error messaging

---

## Emotions

- 🟢 Feels empowered by the visual truck routing interface
- 🟢 Appreciates the simplicity and intuitiveness of shipment-to-truck assignment

---

## Pain Points

- None currently reported in this workflow

---

## Opportunities

- None currently reported in this workflow

---

## Outcome

The user successfully assigned shipments to trucks. The system’s **visual map** and **lightweight controls** allowed them to quickly evaluate geographic alignment and ensure efficient loading. This journey enabled streamlined planning without any errors or confusion.
