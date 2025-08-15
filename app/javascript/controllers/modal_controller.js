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
    // Allow both submit and click handlers; prefer submit events
    if (event) event.preventDefault();

    // Get the truck ID
    const truckId = this.truckIdInput?.value || document.getElementById("modal-truck-id")?.value;

    // Create a form and submit via Turbo
    const form = this.form || event?.target || document.getElementById("initiate-form");
    if (!truckId || !form) return;

    const formData = new FormData(form);

    const submitForm = document.createElement("form");
    submitForm.method = "post";
    submitForm.action = `/shipments/initiate_delivery?truck_id=${truckId}`;

    const csrfTokenMeta = document.querySelector("meta[name='csrf-token']");
    if (csrfTokenMeta?.content) {
      const csrfInput = document.createElement("input");
      csrfInput.type = "hidden";
      csrfInput.name = "authenticity_token";
      csrfInput.value = csrfTokenMeta.content;
      submitForm.appendChild(csrfInput);
    }

    for (const [key, value] of formData.entries()) {
      const input = document.createElement("input");
      input.type = "hidden";
      input.name = key;
      input.value = value;
      submitForm.appendChild(input);
    }

    document.body.appendChild(submitForm);
    submitForm.submit();
  }
}
