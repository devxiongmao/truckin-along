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
    // Allow both submit and click handlers; prefer submit events
    if (event) event.preventDefault();

    const formElement = this.form || event?.target || document.getElementById("maintenance-form");
    const truckId = this.truckIdInput?.value || document.getElementById("modal-truck-id")?.value;
    if (!truckId || !formElement) return;

    const formData = new FormData(formElement);

    const submitForm = document.createElement("form");
    submitForm.method = "post";
    submitForm.action = `/trucks/${truckId}/create_form?truck_id=${truckId}`;

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
