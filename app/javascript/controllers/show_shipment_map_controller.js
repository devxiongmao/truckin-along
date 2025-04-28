import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    senderLat: Number,
    senderLng: Number,
    receiverLat: Number,
    receiverLng: Number,
    senderAddress: String,
    receiverAddress: String
  }

  hasValidCoordinates() {
    return this.hasSenderLatValue && this.hasSenderLngValue &&
           this.hasReceiverLatValue && this.hasReceiverLngValue &&
           this.senderLatValue !== 0 && this.senderLngValue !== 0 &&
           this.receiverLatValue !== 0 && this.receiverLngValue !== 0;
  }

  connect() {
    if (this.hasValidCoordinates()) {
      this.initMap();
    } else {
      this.showError();
    }
  }

  initMap() {
    // Calculate center point
    const centerLat = (this.senderLatValue + this.receiverLatValue) / 2;
    const centerLng = (this.senderLngValue + this.receiverLngValue) / 2;
    
    // Initialize map
    const map = L.map(this.element).setView([centerLat, centerLng], 10);
    
    // Add OpenStreetMap tiles
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);
    
    // Add markers for sender and receiver
    const senderMarker = L.marker([this.senderLatValue, this.senderLngValue]).addTo(map);
    senderMarker.bindPopup("<b>Pickup Location</b><br>" + this.senderAddressValue);
    
    const receiverMarker = L.marker([this.receiverLatValue, this.receiverLngValue]).addTo(map);
    receiverMarker.bindPopup("<b>Delivery Location</b><br>" + this.receiverAddressValue);
    
    // Fit the map to show both markers
    const bounds = L.latLngBounds([
      [this.senderLatValue, this.senderLngValue],
      [this.receiverLatValue, this.receiverLngValue]
    ]);
    map.fitBounds(bounds, { padding: [50, 50] });
  }

  showError() {
    this.element.innerHTML = '<div class="alert alert-warning">Unable to display map. Address coordinates are not available.</div>';
    this.element.style.height = 'auto';
  }
}