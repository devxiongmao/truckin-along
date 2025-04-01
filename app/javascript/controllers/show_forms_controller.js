import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="show-forms"
export default class extends Controller {
  connect() {
    this.modal = document.getElementById('form-modal');
    this.modalBody = document.getElementById('modal-body');
    this.closeBtn = this.modal.querySelector('.close');
  }

  close(event) {
    event.preventDefault();
    this.modal.classList.add("hidden");
  }

  open(event) {
    const formId = event.target.dataset.formId;
  
    // Fetch the form partial
    fetch(`/forms/${formId}/show_modal`)
      .then(response => response.text())
      .then(html => {
        this.modalBody.innerHTML = html;
        this.modal.classList.remove("hidden");
      })
      .catch(error => {
        console.error('Error loading form:', error);
        this.modalBody.innerHTML = '<p>Error loading form.</p>';
        this.modal.classList.remove("hidden");
      });

  }
}
