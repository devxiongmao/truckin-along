# User Journey: Trucking Company Marking a Delivery Complete

## Persona

**Name:** Peter Parker  
**Role:** A driver or admin at a trucking company using the Truckin' Along platform  
**Goal:** Mark a delivery as complete after all shipments have been delivered

---

## Journey Overview

After completing all associated deliveries, the driver (or admin) needs to formally close the delivery in the system. This not only notifies relevant users but also makes the truck available for future assignments and ensures backend processes (like maintenance tracking) are triggered.

---

## Steps

1. **Entry Point: Accessing the Start Deliveries Page**

   - The user navigates to the **Start Deliveries** page from the top navigation bar
   - Route: `/deliveries/start`
   - Example: `http://localhost:3000/deliveries/start`

2. **Viewing the Active Delivery**

   - The user identifies the active delivery and clicks the **`View Delivery`** button
   - Route: `/deliveries/:id`
   - Example: `http://localhost:3000/deliveries/1`

3. **Initiating Delivery Completion**

   - If **all shipments** under the delivery have been marked as delivered or closed, a green **`Mark Complete`** button appears at the top of the Delivery Show page
   - Clicking this button opens a **confirmation modal**
     - User options:
       - `No`: Cancel the action
       - `Yes`: Proceed to confirm closure

4. **Entering Odometer Reading**

   - If the user clicks `Yes`, an additional field appears in the modal requesting the **final odometer reading**
   - The user must enter the correct numeric value
   - If entered incorrectly:
     - The user is redirected back to the Delivery Show page
     - A red error banner appears:
       > `Odometer reading is incorrect. Please revise.`

5. **Confirmation and Completion**

   - If the odometer value is correct and the form is submitted:
     - The user is redirected to the **Start Deliveries** page
     - A green banner appears:
       > `Delivery Complete!`
   - Additionally, system-level backend processes are triggered:
     - The truck may be marked as **inactive** if due for **maintenance**

---

## Emotions

- 🟢 Pleased with how simple and straightforward it is to mark a delivery complete

---

## Pain Points

- None currently reported in this workflow

---

## Opportunities

- **XMDEV-364**: Add input formatting and hint text to odometer field to reduce validation issues (e.g., `e.g., 148723`)
- **XMDEV-363**: Improve error messaging to explain what was incorrect (e.g., “Odometer reading must be higher than starting value”)
- **XMDEV-362**: If the delivery is not eligible for completion (e.g., shipments still open), disable or hide the `Mark Complete` button until criteria are met

---

## Outcome

At the end of the journey, the user successfully marked the delivery as complete, making the truck available for reassignment and triggering backend actions like maintenance checks. While generally efficient, the experience could be improved by refining the odometer input flow and enhancing error clarity.
