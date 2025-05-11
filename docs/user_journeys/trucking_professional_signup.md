# User Journey: Trucking Professional Sign-Up Experience

## Persona

**Name:** Peter Parker, a person matching our standard trucking professional profile  
**Role:** First-time user affiliated with a trucking company  
**Goal:** Sign up for Truckin' Along to manage trucks, drivers, and ship packages

---

## Journey Overview

This user likely discovered Truckin' Along via word of mouth or marketing efforts and is exploring the platform for its potential value. Their expectations include greater efficiency, improved package management, and the ability to generate revenue. They're here to establish a presence on the platform as a trucking professional.

---

## Steps

1. **Entry Point**

   - The user visits the root homepage of Truckin' Along.
   - They see a welcome screen outlining available user roles.
   - They click the `Sign Up as Trucking Professional` link.

2. **Filling Out the Form**

   - The user is presented with a sign-up form requiring the following fields:
     - First Name
     - Last Name
     - Email Address
     - Driver’s License
     - Password
   - The user fills out all six fields.

3. **Submitting the Form**

   - After completing the form, the user clicks the `Sign Up` button.
   - If any errors are present, an alert is shown and the form data remains intact.

4. **Initial Redirect**

   - Upon successful sign-up, the user is redirected back to the homepage.
   - A banner appears at the top:  
     `Welcome! You have signed up successfully.`
   - At this point, the homepage still displays the original sign-up buttons.

5. **Company Creation Trigger**

   - When the user clicks on any navigation link after signing up, they're prompted to create their company.
   - A new form appears requiring:
     - Company Name
     - Company Address
   - The user completes the form and clicks `Save Company`.

6. **Final Step**

   - After creating the company, the user is directed to the page they originally clicked on.
   - They now have full access to the platform’s features as a trucking professional.

---

## Emotions

- 🟢 Pleased with the lightweight sign-up process
- 🟢 Appreciates the minimal cognitive load
- 🟡 Confused by being redirected to the same homepage post-signup
- 🟡 Unclear that they must create a company before using the platform
- 🟡 Confused by the label `Save Company`, which implies support for multiple companies when that is not currently the case

---

## Pain Points

- Lack of clear indication that the user is signed in after account creation
- Disjointed flow between user sign-up and company creation

---

## Opportunities

- Update homepage content post-login to reflect the user’s authenticated state and role more clearly _(XMDEV-316)_
- Prompt trucking professionals to create their company **immediately** after completing personal sign-up _(XMDEV-319)_
- Consider renaming the `Save Company` button to something more accurate, like `Create Company` _(XMDEV-340)_

---

## Outcome

By the end of this journey, the user successfully created both their personal admin account and their associated company profile, gaining full access to the Truckin' Along platform.
