import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    senderLat: Number,
    senderLng: Number,
    receiverLat: Number,
    receiverLng: Number,
    senderAddress: String,
    receiverAddress: String,
    additionalCoordinates: Array
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
    // Calculate center point for the main route
    const centerLat = (this.senderLatValue + this.receiverLatValue) / 2;
    const centerLng = (this.senderLngValue + this.receiverLngValue) / 2;
    
    // Initialize map
    const map = L.map(this.element).setView([centerLat, centerLng], 10);
    
    // Add OpenStreetMap tiles
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);
    
    // Create bounds to encompass all points
    const allPoints = [
      [this.senderLatValue, this.senderLngValue],
      [this.receiverLatValue, this.receiverLngValue]
    ];
    
    // Add markers for main sender and receiver
    const senderMarker = L.marker([this.senderLatValue, this.senderLngValue]).addTo(map);
    senderMarker.bindPopup("<b>Pickup Location</b><br>" + this.senderAddressValue);
    
    const receiverMarker = L.marker([this.receiverLatValue, this.receiverLngValue]).addTo(map);
    receiverMarker.bindPopup("<b>Delivery Location</b><br>" + this.receiverAddressValue);
    
    // Draw the main route in blue
    L.polyline([
      [this.senderLatValue, this.senderLngValue],
      [this.receiverLatValue, this.receiverLngValue]
    ], { color: 'blue', weight: 3 }).addTo(map);
    
    // Process additional coordinates if available
    if (this.hasAdditionalCoordinatesValue && this.additionalCoordinatesValue.length > 0) {
      this.additionalCoordinatesValue.forEach((coord, index) => {
        // Check if this additional coordinate has valid data
        if (this.isValidAdditionalCoordinate(coord)) {
          // Add to the bounds calculation
          allPoints.push([coord.senderLat, coord.senderLng]);
          allPoints.push([coord.receiverLat, coord.receiverLng]);
          
          // Add markers for this segment
          const segmentSenderMarker = L.marker([coord.senderLat, coord.senderLng]).addTo(map);
          segmentSenderMarker.bindPopup(`<b>Waypoint ${index + 1}</b><br>${coord.senderAddress}`);
          
          const segmentReceiverMarker = L.marker([coord.receiverLat, coord.receiverLng]).addTo(map);
          segmentReceiverMarker.bindPopup(`<b>Waypoint ${index + 2}</b><br>${coord.receiverAddress}`);
          
          // Draw this segment route in red
          L.polyline([
            [coord.senderLat, coord.senderLng],
            [coord.receiverLat, coord.receiverLng]
          ], { color: 'red', weight: 2 }).addTo(map);
        }
      });
    }
    
    // Fit the map to show all markers
    const bounds = L.latLngBounds(allPoints);
    map.fitBounds(bounds, { padding: [50, 50] });
  }
  
  isValidAdditionalCoordinate(coord) {
    return coord &&
           typeof coord.senderLat === 'number' && typeof coord.senderLng === 'number' &&
           typeof coord.receiverLat === 'number' && typeof coord.receiverLng === 'number' &&
           coord.senderLat !== 0 && coord.senderLng !== 0 &&
           coord.receiverLat !== 0 && coord.receiverLng !== 0;
  }

  showError() {
    this.element.innerHTML = '<div class="alert alert-warning">Unable to display map. Address coordinates are not available.</div>';
    this.element.style.height = 'auto';
  }
}