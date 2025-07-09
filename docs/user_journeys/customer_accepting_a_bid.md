Under Construction

# User Journey: Customer Accepting/Rejecting a Bid

## Persona

**Name:** John Doe, a person matching our standard customer profile  
**Role:** Customer  
**Goal:** Review and accept bids on their shipments through Truckin' Along

---

## Journey Overview

Now that the user has submitted a shipment, they can receive bids from shipping companies to deliver their shipments. This user journey details them reviewing the bids, and selecting one.

---

## Steps

1. **Entry Point**

   - After logging in, the user navigates to the Offers menu.
   - Route: `/offers` (http://localhost:3000/offers)

2. **Reviewing the Bids**

   - On this page, for each shipment, there are a list of bids that companies have submitted

3. **Accepting a bid**

   - After reviewing the bids for each shipment, the user can click the Accept button to...
     - Reject all other bids
     - Accept the companies offer
   - The offers include...
     - Offers to pickup at the home location
     - Deliver directly to the home address
     - The price
   - If the company is not willing to deliver directly to the home address, they can make the shipment available for pickup at the destination location close to the destination address.

4. **Rejecting a bid**

   - Alternatively, the user can reject an individual bid by clicking the Reject button.
   - This will allow the company to submit a different, more enticing offer.

5. **Monitoring an accepted offer**
   - Once the user has accepted an offer, they can proceed to the [monitoring shipment](customer_monitoring_shipment.md) workflow.

---

## Emotions

- 🟢 Happy with the streamlined process
- 🟢 Appreciate the email notifications to keep them in the loop.

---

## Pain Points

- None currently reported in this workflow

---

## Opportunities

- None currently reported in this workflow

---

## Outcome

The customer was able to easily review the bids they've received for their shipments as well as easily accept or reject bids that have come in.
