import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bulk-offer-modal"
export default class extends Controller {
  static targets = [
    "modal", 
    "form", 
    "shipmentContainer",
    "submitBtn",
    "closeBtn"
  ]
  
  connect() {
    this.modalTarget.style.display = "none"
  }
  
  showModal(event) {
    event.preventDefault()
    
    // Get selected shipment checkboxes
    const selectedShipments = document.querySelectorAll('input[name="shipment_ids[]"]:checked')
    
    if (selectedShipments.length === 0) {
      alert('Please select at least one shipment to create offers for.')
      return
    }
    
    // Clear previous shipment entries
    this.shipmentContainerTarget.innerHTML = ''
    
    // Create form entries for each selected shipment
    selectedShipments.forEach((checkbox, index) => {
      const shipmentId = checkbox.value
      const shipmentRow = checkbox.closest('tr')
      const shipmentName = shipmentRow.querySelector('td:nth-child(3)').textContent.trim()
      const senderAddress = shipmentRow.querySelector('td:nth-child(4)').textContent.trim()
      const receiverAddress = shipmentRow.querySelector('td:nth-child(5)').textContent.trim()
      const weight = shipmentRow.querySelector('td:nth-child(6)').textContent.trim()
      
      const shipmentEntry = this.createShipmentEntry(shipmentId, shipmentName, senderAddress, receiverAddress, weight, index)
      this.shipmentContainerTarget.appendChild(shipmentEntry)
    })
    
    // Show modal
    this.modalTarget.style.display = "flex"
  }
  
  hideModal() {
    this.modalTarget.style.display = "none"
  }
  
  createShipmentEntry(shipmentId, shipmentName, senderAddress, receiverAddress, weight, index) {
    const entry = document.createElement('div')
    entry.className = 'shipment-entry'
    entry.innerHTML = `
      <div class="shipment-header">
        <h4>Shipment: ${shipmentName}</h4>
        <p><strong>From:</strong> ${senderAddress}</p>
        <p><strong>To:</strong> ${receiverAddress}</p>
        <p><strong>Weight:</strong> ${weight}</p>
      </div>
      
      <div class="offer-fields">
        <div class="form-group">
          <label for="price_${index}">Offer Price ($):</label>
          <input type="number" 
                 id="price_${index}" 
                 name="offers[${index}][price]" 
                 step="0.01" 
                 min="0" 
                 required 
                 class="form-input">
        </div>
        
        <div class="form-group">
          <label>
            <input type="checkbox" 
                   id="pickup_from_sender_${index}"
                   data-action="change->bulk-offer-modal#toggleReceptionAddress"
                   data-index="${index}"
                   checked>
            Pickup from sender
          </label>
          <input type="hidden" 
                 name="offers[${index}][pickup_from_sender]" 
                 value="1">
        </div>
        
        <div class="form-group reception-address-group" id="reception_address_${index}" style="display: none;">
          <label for="reception_address_input_${index}">Reception Address:</label>
          <input type="text" 
                 id="reception_address_input_${index}" 
                 name="offers[${index}][reception_address]" 
                 class="form-input">
        </div>
        
        <div class="form-group">
          <label>
            <input type="checkbox" 
                   id="deliver_to_door_${index}"
                   data-action="change->bulk-offer-modal#toggleDropoffLocation"
                   data-index="${index}"
                   checked>
            Deliver to door
          </label>
          <input type="hidden" 
                 name="offers[${index}][deliver_to_door]" 
                 value="1">
        </div>
        
        <div class="form-group dropoff-location-group" id="dropoff_location_${index}" style="display: none;">
          <label for="dropoff_location_input_${index}">Dropoff Location:</label>
          <input type="text" 
                 id="dropoff_location_input_${index}" 
                 name="offers[${index}][dropoff_location]" 
                 class="form-input">
          
          <div class="form-group" style="margin-top: 10px;">
            <label>
              <input type="checkbox" 
                     id="pickup_at_dropoff_${index}"
                     data-action="change->bulk-offer-modal#updatePickupAtDropoff"
                     data-index="${index}">
              Pickup at dropoff location
            </label>
            <input type="hidden" 
                   name="offers[${index}][pickup_at_dropoff]" 
                   value="0">
          </div>
        </div>
        
        <div class="form-group">
          <label for="notes_${index}">Notes:</label>
          <textarea id="notes_${index}" 
                    name="offers[${index}][notes]" 
                    class="form-input" 
                    rows="3" 
                    placeholder="Any additional notes for this shipment..."></textarea>
        </div>
        
        <!-- Hidden fields -->
        <input type="hidden" name="offers[${index}][shipment_id]" value="${shipmentId}">
        <input type="hidden" name="offers[${index}][company_id]" value="${this.getCurrentCompanyId()}">
      </div>
    `
    
    return entry
  }
  
  toggleReceptionAddress(event) {
    const index = event.target.dataset.index
    const receptionAddressGroup = document.getElementById(`reception_address_${index}`)
    const receptionAddressInput = document.getElementById(`reception_address_input_${index}`)
    const hiddenField = document.querySelector(`input[name="offers[${index}][pickup_from_sender]"]`)
    
    if (event.target.checked) {
      receptionAddressGroup.style.display = 'none'
      receptionAddressInput.removeAttribute('required')
      receptionAddressInput.value = ''
      hiddenField.value = '1'
    } else {
      receptionAddressGroup.style.display = 'block'
      receptionAddressInput.setAttribute('required', 'required')
      hiddenField.value = '0'
    }
  }
  
  toggleDropoffLocation(event) {
    const index = event.target.dataset.index
    const dropoffLocationGroup = document.getElementById(`dropoff_location_${index}`)
    const dropoffLocationInput = document.getElementById(`dropoff_location_input_${index}`)
    const hiddenField = document.querySelector(`input[name="offers[${index}][deliver_to_door]"]`)
    
    if (event.target.checked) {
      dropoffLocationGroup.style.display = 'none'
      dropoffLocationInput.removeAttribute('required')
      dropoffLocationInput.value = ''
      hiddenField.value = '1'
    } else {
      dropoffLocationGroup.style.display = 'block'
      dropoffLocationInput.setAttribute('required', 'required')
      hiddenField.value = '0'
    }
  }
  
  updatePickupAtDropoff(event) {
    const index = event.target.dataset.index
    const hiddenField = document.querySelector(`input[name="offers[${index}][pickup_at_dropoff]"]`)
    hiddenField.value = event.target.checked ? '1' : '0'
  }
  
  getCurrentCompanyId() {
    // This should be set in the view or retrieved from a data attribute
    return this.element.dataset.companyId || ''
  }
  
  submitForm() {
    // Validate that at least one shipment is selected
    const selectedShipments = document.querySelectorAll('input[name="shipment_ids[]"]:checked')
    if (selectedShipments.length === 0) {
      alert('Please select at least one shipment to create offers for.')
      return
    }
    
    // Submit the form
    this.formTarget.submit()
  }
} 