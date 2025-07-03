import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="complete-delivery"
export default class extends Controller {
  static targets = [
    "modal", 
    "confirmBtn", 
    "cancelBtn", 
    "form", 
    "odometerInput", 
    "odometerContainer"
  ]
  
  connect() {
    this.modalTarget.style.display = "none"
    this.odometerContainerTarget.style.display = "none"
  }
  
  showModal(event) {
    event.preventDefault()
    
    // Show modal
    this.modalTarget.style.display = "flex"
  }
  
  hideModal() {
    this.modalTarget.style.display = "none"
    
    // Reset odometer input if shown
    this.odometerContainerTarget.style.display = "none"
    this.odometerInputTarget.value = ""
  }
  
  showOdometerInput() {
    // Show odometer input field when "Yes" is clicked
    this.odometerContainerTarget.style.display = "block"
  }
  
  submitWithOdometer() {
    // Create a hidden input with the new odometer value
    const odometerInput = document.createElement("input")
    odometerInput.type = "hidden"
    odometerInput.name = "odometer_reading"
    odometerInput.value = this.odometerInputTarget.value
    
    // Append to form and submit
    this.formTarget.appendChild(odometerInput)
    this.formTarget.submit()
  }
}