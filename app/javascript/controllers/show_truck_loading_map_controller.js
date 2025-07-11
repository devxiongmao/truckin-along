import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="show-truck-loading-map"
export default class extends Controller {
  static values = {
    shipmentsJson: String
  }

  connect() {
    this.shipments = JSON.parse(this.shipmentsJsonValue);

    if (this.hasShipmentsWithValidCoordinates()) {
      this.initMap();
    } else {
      this.showError();
    }
  }

  hasShipmentsWithValidCoordinates() {
    return this.shipments.length > 0 && 
           this.shipments.some(shipment => this.hasValidCoordinates(shipment));
  }

  hasValidCoordinates(shipment) {
    return (
      shipment.current_sender_latitude != null &&
      shipment.current_sender_longitude != null &&
      shipment.current_receiver_latitude != null &&
      shipment.current_receiver_longitude != null &&
      shipment.current_sender_latitude !== 0 &&
      shipment.current_sender_longitude !== 0 &&
      shipment.current_receiver_latitude !== 0 &&
      shipment.current_receiver_longitude !== 0
    );
  }

  initMap() {
    const map = L.map(this.element).setView([0, 0], 2);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

    const bounds = L.latLngBounds();

    this.shipments.forEach((shipment, index) => {
      if (this.hasValidCoordinates(shipment)) {
        const senderMarker = L.marker([shipment.current_sender_latitude, shipment.current_sender_longitude]).addTo(map);
        senderMarker.bindPopup(`<b>Pickup Location ${index + 1}</b><br>${shipment.current_sender_address}`);

        const receiverMarker = L.marker([shipment.current_receiver_latitude, shipment.current_receiver_longitude]).addTo(map);
        receiverMarker.bindPopup(`<b>Delivery Location ${index + 1}</b><br>${shipment.current_receiver_address}`);

        L.polyline([
          [shipment.current_sender_latitude, shipment.current_sender_longitude],
          [shipment.current_receiver_latitude, shipment.current_receiver_longitude]
        ], {
          color: this.getRouteColor(index),
          weight: 3,
          opacity: 0.7
        }).addTo(map);

        bounds.extend([shipment.current_sender_latitude, shipment.current_sender_longitude]);
        bounds.extend([shipment.current_receiver_latitude, shipment.current_receiver_longitude]);
      }
    });

    if (bounds.isValid()) {
      map.fitBounds(bounds, { padding: [50, 50] });
    }
  }

  getRouteColor(index) {
    const colors = ['#3388ff', '#ff3333', '#33cc33', '#9933cc', '#ff9900', '#00ccff'];
    return colors[index % colors.length];
  }

  showError() {
    this.element.innerHTML = '<div class="alert alert-warning">Unable to display map. No valid shipment coordinates available.</div>';
    this.element.style.height = 'auto';
  }
}
