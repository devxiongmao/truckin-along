# User Journey: Admin Creating Another Truck

## Persona

**Name:** Peter Parker, an admin user of a trucking company called _Truckit_  
**Role:** Admin, returning user  
**Goal:** Create a new truck in the system to be used for future deliveries

---

## Journey Overview

As trucking companies grow, they acquire new vehicles to expand or replace their fleets. Admin users of such companies use the Truckin' Along platform to model and track these trucks. This journey outlines the process by which an admin creates a new truck, ensures it appears within the system, and completes its initial maintenance record.

---

## Steps

1. **Entry Point**

   - The user logs in and navigates to the Admin dashboard via the site’s top navigation bar.
   - Route: `/admin` (e.g., http://localhost:3000/admin)

2. **Initiate Truck Creation**

   - From the Admin dashboard, the user clicks the `Create New Truck` button.
   - They are redirected to the truck creation form: `/trucks/new`.

3. **Fill Out the New Truck Form**

   - The user is prompted to enter several truck-specific fields:
     - Make
     - Model
     - Year
     - Mileage
     - VIN #
     - License Plate
     - Haul Weight (kg)
     - Bed Dimensions (Length, Width, Height in cm)
   - If some information is unavailable:
     - The user may enter placeholder data (which must be updated before the truck can be dispatched), or
     - Exit and return to complete the form at a later time.

4. **Save the Truck**

   - After filling out the form, the user clicks `Save Truck`.
   - On success:
     - They are redirected to the Admin dashboard.
     - A confirmation banner appears at the top of the page.
   - On failure:
     - An error message is displayed.
     - All form inputs are preserved, minimizing rework.

5. **Truck Confirmation**

   - On the Admin dashboard, the newly created truck appears in the `Trucks` section, confirming its successful addition to the platform.

6. **Complete Initial Maintenance**

   - Next to the newly created truck entry, an orange `Maintenance` button is visible.
   - Clicking the button opens a modal labeled `Maintenance Form`.

7. **Fill Out the Maintenance Form**

   - The form includes the following fields:
     - Maintenance Title
     - Date of Completion
     - Current Mileage
     - Confirmation checkboxes for:
       - Oil Change
       - Tire Pressure Check
     - Optional Notes section
   - The user completes the form and clicks `Confirm and Submit`.
   - On successful submission, maintenance data is linked to the truck’s profile.

---

## Emotions

- 🟢 Feels accomplished after a smooth and intuitive truck creation flow
- 🟢 Appreciates low cognitive effort required for basic operations
- 🟡 Slightly frustrated if required truck data is not immediately available
- 🔴 Frustrated that only admins can complete maintenance records, adding overhead

---

## Pain Points

- Truck creation requires all data up front:
  - Missing data means either placeholder input (which must be corrected) or a delayed form submission
- Only admin users can complete truck maintenance, limiting operational flexibility

---

## Opportunities

- **XMDEV-347**: Enable drivers to fill out and submit maintenance forms, reducing admin burden and increasing real-time accuracy

---

## Outcome

The user successfully created and configured a new truck with minimal friction. Maintenance was recorded at the time of creation, making the truck fully operational and visible within the platform. The process was straightforward, but the admin's role in maintenance could be better distributed across other user types.
