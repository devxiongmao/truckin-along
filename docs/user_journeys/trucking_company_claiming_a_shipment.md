# User Journey: Trucking Company Claiming a Shipment

## Persona

**Name:** Peter Parker  
**Role:** Driver or admin associated with a trucking company using the Truckin' Along platform  
**Goal:** Submit bids to claim customer shipments for delivery—either partially or in full—to generate revenue for the company

---

## Journey Overview

When a customer posts a shipment to the Truckin' Along platform, trucking companies have the opportunity to claim and deliver it. This journey follows a user—driver or admin—who is browsing the available deliveries, reviewing shipment details, submitting bids, and awaiting customer approval. Claiming a shipment kicks off the delivery lifecycle and allows companies to earn income through successful drop-offs.

---

## Steps

1. **Entry Point**

   - The user accesses the **Shipment Marketplace** via the top navigation bar
   - Route: `/deliveries` (e.g., http://localhost:3000/deliveries)

2. **Investigate Available Shipments**

   - The marketplace displays both **available** and **claimed** shipments
   - The user can:
     - Quickly scan each shipment
     - Click **`Show Details`** to open the full Shipment page (`/shipments/:id`) for more info, including:
       - Pickup and dropoff locations
       - Expected delivery window
       - Package details

3. **Select Shipments to Bid On**

   - Once a shipment looks like a good fit, the user can:
     - Check the box beside that shipment (multiple selections allowed)
     - Click the **`Assign to Me`** button to proceed (this button launches the bid modal)

4. **Complete the Bid Form**

   - A modal appears prompting the user to enter the following for each shipment:
     - **Estimated Delivery Date**
     - **Delivery Location**
     - **Dropoff vs. Pickup Preference**
     - **Offered Price**
     - **Bid Expiry Date**
   - Once all required fields are completed, the user clicks **`Submit`**

5. **Asynchronous Follow-Up: Bid Accepted**

   - If a **customer accepts** the submitted bid:
     - The user receives an **email notification**
     - The shipment is automatically assigned to the user's trucking company

---

## Emotions

- 🟢 Pleased with the easy and streamlined bid submission process
- 🟢 Appreciates the flexibility to choose multiple shipments and customize offers
- 🟡 Finds it hard to **quickly identify shipment destinations** at a glance
- 🟡 Mild confusion over the **`Assign to Me`** button, which implies finality rather than a bid submission

---

## Pain Points

- Important shipment info—like **pickup/dropoff location** and **time window**—is buried in the details page
- The **`Assign to Me`** button is misleading, especially since users are actually submitting a bid, not claiming ownership yet

---

## Opportunities

- **XMDEV-350**: Rename **`Assign to Me`** button to **`Submit Bids`** for clarity
- **XMDEV-309**: Fully implement a structured bidding system, enhancing scalability and transparency
- Improve shipment preview cards to **display key details** (location, timing) without requiring a deep dive

---

## Outcome

The user successfully submitted one or more bids for available shipments. The process was intuitive, efficient, and allowed for batch bidding. With minor adjustments to terminology and UX, the journey can become even more transparent and driver-friendly.
