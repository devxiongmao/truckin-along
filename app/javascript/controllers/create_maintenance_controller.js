import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="create-maintenance"
export default class extends Controller {
  connect() {
    this.modal = document.getElementById("maintenance-modal");
    this.form = document.getElementById("maintenance-form");
    this.truckIdInput = document.getElementById("modal-truck-id");
  }

  open(event) {
    event.preventDefault();
    const truckId = event.currentTarget.dataset.modalTruckIdValue;
    
    // Continue with your code...
    this.truckIdInput.value = truckId;
    this.modal.classList.remove("hidden");
  }

  close(event) {
    event.preventDefault();
    this.modal.classList.add("hidden");
  }

  submitForm(event) {
    event.preventDefault();
  
    // Get the truck ID
    const truckId = this.truckIdInput.value;
    
    // Get form values
    const form = event.target;
    const formData = new FormData(form);
    
    // Create a new form for submission
    const submitForm = document.createElement("form");
    submitForm.method = "post";

    submitForm.action = `/trucks/${truckId}/create_form?truck_id=${truckId}`;
    
    // Add CSRF token
    const csrfToken = document.querySelector("meta[name='csrf-token']").content;
    const csrfInput = document.createElement("input");
    csrfInput.type = "hidden";
    csrfInput.name = "authenticity_token";
    csrfInput.value = csrfToken;
    submitForm.appendChild(csrfInput);
    
    // Add all form fields from the original form
    for (const [key, value] of formData.entries()) {
      const input = document.createElement("input");
      input.type = "hidden";
      input.name = key;
      input.value = value;
      submitForm.appendChild(input);
    }
    
    // Submit the form
    document.body.appendChild(submitForm);
    submitForm.submit();
  }
}
