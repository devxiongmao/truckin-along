# User Journey: Admin Creating Another Driver

## Persona

**Name:** Peter Parker, an admin user of a trucking company called Truckit.  
**Role:** Admin, returning user  
**Goal:** The user would like to create a new profile for a recently hired driver

---

## Journey Overview

Trucking companies regularly hire new drivers. As such, admins of companies within Truckin' Along want to craft new profiles for these newly hired drivers so they can take advantage of Truckin' Along too.

---

## Steps

1. **Entry Point**

   - The user goes to the Admin page of the app by accessing it via the nav bar.
   - `/admin` route (http://localhost:3000/admin)

2. **Click the Create New Driver Button**

   - User clicks a button which brings them to the new driver creation form.
   - Click a button, page changes to this route: `/driver_managements/new`

3. **Fill Out New Driver Form**

   - User needs to fill out the form. They need to have the First Name, Last Name, Driver's License, and Email of the new driver ready.
   - The admin selects a standard password initially that the driver can change upon first login.
   - If the admin does not have all information at the start, they need to either enter placeholder data or come back to this step later.

4. **Create the Driver**

   - Once the form is filled out, user hits the "Create Driver" button.
   - Click a button, and user is redirected to the admin page (Step 1). A successful creation of a driver will result in a banner at the top of the screen confirming the driver was successfully created.
   - If errors occur, the user will be alerted and the page will reload with all previously entered information.

5. **Optional: Verification From New Driver**

   - Admin user then tells the new driver about the new account that has been created for them.

6. **Final Step**

   - On the admin page, the new driver is listed under the `Drivers` section, thereby confirming the driver was successfully created.

---

## Emotions

- 🟢 Happy with easy driver creation
- 🟢 Accomplishes the goal of creating a new driver
- 🟡 May be slightly annoyed at Step 3—if they don't have the new driver's license at the time of creation, they'll either need to enter a placeholder (which must be updated before the driver can take on deliveries), or come back to the form later. Alternatively, the driver can update the information once they log in.
- 🟡 Having the admin select a password for the new driver, only for it to be changed later, is potentially annoying. It seems like an extra, ultimately unnecessary step.

---

## Pain Points

- Possibly not having all new driver information up front. Requires the admin or driver to come back later.
- Admin is required to think of a temporary password that the driver will ideally change upon a subsequent login. This feels like wasted effort.

---

## Opportunities

- Admin shouldn't be required to think of a temporary password for a user. The app should generate a temp password and email it to the user. (XMDEV-317)

---

## Outcome

The user succeeded in creating a new driver. Minimal effort required, minimal cognitive load required.
