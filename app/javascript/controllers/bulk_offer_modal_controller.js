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
      const shipmentData = this.extractShipmentData(shipmentRow)
      
      const shipmentEntry = this.createShipmentEntry(shipmentId, shipmentData, index)
      this.shipmentContainerTarget.appendChild(shipmentEntry)
    })
    
    // Show modal
    this.modalTarget.style.display = "flex"
  }
  
  hideModal() {
    this.modalTarget.style.display = "none"
  }
  
  extractShipmentData(shipmentRow) {
    return {
      name: shipmentRow.querySelector('td:nth-child(3)')?.textContent.trim() || '',
      senderAddress: shipmentRow.querySelector('td:nth-child(4)')?.textContent.trim() || '',
      receiverAddress: shipmentRow.querySelector('td:nth-child(5)')?.textContent.trim() || '',
      weight: shipmentRow.querySelector('td:nth-child(6)')?.textContent.trim() || ''
    }
  }
  
  createShipmentEntry(shipmentId, shipmentData, index) {
    const entry = document.createElement('div')
    entry.className = 'shipment-entry'
    entry.innerHTML = `
      <div class="shipment-header">
        <h4>Shipment: ${shipmentData.name}</h4>
        <p><strong>From:</strong> ${shipmentData.senderAddress}</p>
        <p><strong>To:</strong> ${shipmentData.receiverAddress}</p>
        <p><strong>Weight:</strong> ${shipmentData.weight}</p>
      </div>
      
      <div class="offer-fields">
        <!-- Rails-style nested attributes with proper indexing -->
        <input type="hidden" name="bulk_offer[offers_attributes][${index}][shipment_id]" value="${shipmentId}">
        
        <div class="form-group">
          <label for="offer_price_${index}">Offer Price ($):</label>
          <input type="number" 
                 id="offer_price_${index}" 
                 name="bulk_offer[offers_attributes][${index}][price]" 
                 step="0.01" 
                 min="0" 
                 required 
                 class="form-input">
        </div>
        
        <div class="form-group">
          <!-- Hidden input MUST come before checkbox -->
          <input type="hidden" 
                 name="bulk_offer[offers_attributes][${index}][pickup_from_sender]" 
                 value="0">
          <label>
            <input type="checkbox" 
                   id="pickup_from_sender_${index}"
                   name="bulk_offer[offers_attributes][${index}][pickup_from_sender]"
                   value="1"
                   data-action="change->bulk-offer-modal#toggleReceptionAddress"
                   data-index="${index}"
                   checked>
            Pickup from sender
          </label>
        </div>
        
        <div class="form-group reception-address-group" 
             id="reception_address_group_${index}" 
             style="display: none;">
          <label for="reception_address_${index}">Reception Address:</label>
          <input type="text" 
                 id="reception_address_${index}" 
                 name="bulk_offer[offers_attributes][${index}][reception_address]" 
                 class="form-input">
        </div>
        
        <div class="form-group">
          <!-- Hidden input MUST come before checkbox -->
          <input type="hidden" 
                 name="bulk_offer[offers_attributes][${index}][deliver_to_door]" 
                 value="0">
          <label>
            <input type="checkbox" 
                   id="deliver_to_door_${index}"
                   name="bulk_offer[offers_attributes][${index}][deliver_to_door]"
                   value="1"
                   data-action="change->bulk-offer-modal#toggleDropoffLocation"
                   data-index="${index}"
                   checked>
            Deliver to door
          </label>
        </div>
        
        <div class="form-group dropoff-location-group" 
             id="dropoff_location_group_${index}" 
             style="display: none;">
          <label for="dropoff_location_${index}">Dropoff Location:</label>
          <input type="text" 
                 id="dropoff_location_${index}" 
                 name="bulk_offer[offers_attributes][${index}][dropoff_location]" 
                 class="form-input">
          
          <div class="form-group" style="margin-top: 10px;">
            <!-- Hidden input MUST come before checkbox -->
            <input type="hidden" 
                   name="bulk_offer[offers_attributes][${index}][pickup_at_dropoff]" 
                   value="0">
            <label>
              <input type="checkbox" 
                     id="pickup_at_dropoff_${index}"
                     name="bulk_offer[offers_attributes][${index}][pickup_at_dropoff]"
                     value="1">
              Pickup at dropoff location
            </label>
          </div>
        </div>
        
        <div class="form-group">
          <label for="offer_notes_${index}">Notes:</label>
          <textarea id="offer_notes_${index}" 
                    name="bulk_offer[offers_attributes][${index}][notes]" 
                    class="form-input" 
                    rows="3" 
                    placeholder="Any additional notes for this shipment..."></textarea>
        </div>
      </div>
    `
    
    return entry
  }
  
  toggleReceptionAddress(event) {
    const index = event.target.dataset.index
    const receptionAddressGroup = document.getElementById(`reception_address_group_${index}`)
    const receptionAddressInput = document.getElementById(`reception_address_${index}`)
    
    if (event.target.checked) {
      receptionAddressGroup.style.display = 'none'
      receptionAddressInput.removeAttribute('required')
      receptionAddressInput.value = ''
    } else {
      receptionAddressGroup.style.display = 'block'
      receptionAddressInput.setAttribute('required', 'required')
    }
  }
  
  toggleDropoffLocation(event) {
    const index = event.target.dataset.index
    const dropoffLocationGroup = document.getElementById(`dropoff_location_group_${index}`)
    const dropoffLocationInput = document.getElementById(`dropoff_location_${index}`)
    
    if (event.target.checked) {
      dropoffLocationGroup.style.display = 'none'
      dropoffLocationInput.removeAttribute('required')
      dropoffLocationInput.value = ''
    } else {
      dropoffLocationGroup.style.display = 'block'
      dropoffLocationInput.setAttribute('required', 'required')
    }
  }
  
  submitForm(event) {
    event?.preventDefault()
    
    // Basic validation
    const priceInputs = this.shipmentContainerTarget.querySelectorAll('input[type="number"]')
    let isValid = true
    
    priceInputs.forEach(input => {
      if (!input.value || parseFloat(input.value) <= 0) {
        isValid = false
        input.classList.add('error')
      } else {
        input.classList.remove('error')
      }
    })
    
    if (!isValid) {
      alert('Please enter valid prices for all offers.')
      return
    }
  
    this.formTarget.submit()
  }
}