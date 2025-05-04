import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="truck-loading-modal"
export default class extends Controller {
  static targets = [
    "modal", 
    "confirmBtn", 
    "cancelBtn", 
    "form", 
    "addressInput", 
    "addressContainer"
  ]
  
  connect() {
    this.modalTarget.style.display = "none"
    this.addressContainerTarget.style.display = "none"
  }
  
  showModal(event) {
    event.preventDefault()
    
    // Show modal
    this.modalTarget.style.display = "flex"
  }
  
  hideModal() {
    this.modalTarget.style.display = "none"
    
    // Reset address input if shown
    this.addressContainerTarget.style.display = "none"
    this.addressInputTarget.value = ""
  }
  
  confirmDelivery() {
    // Submit the form
    this.formTarget.submit()
  }
  
  showAddressInput() {
    // Show address input field when "No" is clicked
    this.addressContainerTarget.style.display = "block"
  }
  
  submitWithAddress() {
    // Create a hidden input with the new address value
    const addressInput = document.createElement("input")
    addressInput.type = "hidden"
    addressInput.name = "delivery_address"
    addressInput.value = this.addressInputTarget.value
    
    // Append to form and submit
    this.formTarget.appendChild(addressInput)
    this.formTarget.submit()
  }
}