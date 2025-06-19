# User Journey: Customer Monitoring Shipments

## Persona

**Name:** John Doe, a person matching our standard customer profile  
**Role:** Customer  
**Goal:** Monitor the delivery status of a shipment

---

## Journey Overview

The customer wants to track the progress of their shipment to understand how far along it is in the delivery process. They expect visibility into the shipment’s current status, updates along its journey, and confidence that it is being handled by a reliable carrier.

---

## Steps

1. **Entry Point**

   - After logging in, the user navigates to the `Shipments` menu.
   - URL: `/shipments` (e.g., http://localhost:3000/shipments)

2. **Locating the Shipment**

   - The user scrolls through the list of shipments.
   - Once they identify the desired shipment, they click the `Show` button beside it.

3. **Viewing Shipment Details**

   - The user is taken to the shipment show page at `/shipments/:id`.
   - A map is displayed, showing incremental deliveries.
   - The user can scroll down to view detailed information about each delivery stop.

4. **Async Notification: Shipment Claimed**

   - When a trucking company claims the shipment, the user receives an email notifying them that the shipment has been picked up.

5. **Async Notification: Shipment Delivered (Incrementally)**

   - As the shipment progresses and is delivered to intermediary locations, the user receives email notifications with each update.

6. **Wrap-Up**

   - After reviewing the details and tracking progress, the user feels informed and confident.
   - They close the browser, satisfied with the transparency of the process.

---

## Emotions

- 🟢 Feels well-informed by email notifications about shipment activity
- 🟢 Appreciates the straighforward and clear layout of the shipment details page, showing incremental deliveries
- 🟢 Appreciates being able to track the shipment and identify and contact the carrier
- 🟢 Apperciates the ease of identifying the correct shipment on the index page

---

## Pain Points

- None currently reported in this workflow

---

## Opportunities

- Maintain and improve shipment-claimed email notifications _(XMDEV-343)_

---

## Outcome

The user successfully tracked the status of their shipment and received clear communication along the way. They were able to identify who handled their package and had a viable support path if needed.
