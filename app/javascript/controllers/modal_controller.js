import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { truckId: Number }

  connect() {
    this.modal = document.getElementById("initiate-modal");
    this.form = document.getElementById("initiate-form");
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

    // Create a form and submit via Turbo
    const form = document.createElement("form");
    form.method = "post";
    form.action = `/shipments/initiate_delivery?truck_id=${truckId}`;
    
    // Add CSRF token
    const csrfToken = document.querySelector("meta[name='csrf-token']").content;
    const csrfInput = document.createElement("input");
    csrfInput.type = "hidden";
    csrfInput.name = "authenticity_token";
    csrfInput.value = csrfToken;
    
    form.appendChild(csrfInput);
    document.body.appendChild(form);
    form.submit();
  }
}
