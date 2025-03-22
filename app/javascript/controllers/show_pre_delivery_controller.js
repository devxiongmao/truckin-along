import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="show-pre-delivery"
export default class extends Controller {
  connect() {
    console.log("connected")
    this.modal = document.getElementById("initiate-modal");
  }

  open(event) {
    console.log("openned")

    event.preventDefault();
    this.modal.classList.remove("hidden");
  }

  close(event) {
    console.log("closed")

    event.preventDefault();
    this.modal.classList.add("hidden");
  }
}
