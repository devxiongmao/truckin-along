import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="show-pre-delivery"
export default class extends Controller {
  connect() {
    this.modal = document.getElementById("initiate-modal");
  }

  open(event) {
    event.preventDefault();
    this.modal.classList.remove("hidden");
  }

  close(event) {
    event.preventDefault();
    this.modal.classList.add("hidden");
  }
}
