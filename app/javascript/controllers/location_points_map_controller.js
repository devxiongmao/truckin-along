import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="location-points-map"
export default class extends Controller {
  static values = {
    pointsJson: String
  }

  connect() {
    this.points = JSON.parse(this.pointsJsonValue);

    if (this.hasValidPoints()) {
      this.initMap();
    } else {
      this.showError();
    }
  }

  hasValidPoints() {
    return this.points.length > 0 && 
           this.points.some(point => this.hasValidCoordinates(point));
  }

  hasValidCoordinates(point) {
    return (
      point.current_sender_latitude != null &&
      point.current_sender_longitude != null &&
      point.current_receiver_latitude != null &&
      point.current_receiver_longitude != null &&
      point.current_sender_latitude !== 0 &&
      point.current_sender_longitude !== 0 &&
      point.current_receiver_latitude !== 0 &&
      point.current_receiver_longitude !== 0
    );
  }

  initMap() {
    const map = L.map(this.element).setView([0, 0], 2);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

    const bounds = L.latLngBounds();

    // Create custom icons for start and end points
    const startIcon = L.icon({
      iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png',
      shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41]
    });

    const endIcon = L.icon({
      iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png',
      shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41]
    });

    this.points.forEach((point, index) => {
      if (this.hasValidCoordinates(point)) {
        // Add start location marker (red)
        const startMarker = L.marker([point.current_sender_latitude, point.current_sender_longitude], { icon: startIcon }).addTo(map);
        const startPopupContent = point.current_sender_address ? 
          `<b>Start Location ${index + 1}</b><br>${point.current_sender_address}` : 
          `<b>Start Location ${index + 1}</b><br>Lat: ${point.current_sender_latitude}, Lng: ${point.current_sender_longitude}`;
        startMarker.bindPopup(startPopupContent);

        // Add end location marker (blue)
        const endMarker = L.marker([point.current_receiver_latitude, point.current_receiver_longitude], { icon: endIcon }).addTo(map);
        const endPopupContent = point.current_receiver_address ? 
          `<b>End Location ${index + 1}</b><br>${point.current_receiver_address}` : 
          `<b>End Location ${index + 1}</b><br>Lat: ${point.current_receiver_latitude}, Lng: ${point.current_receiver_longitude}`;
        endMarker.bindPopup(endPopupContent);

        // Add connecting line between start and end points
        L.polyline([
          [point.current_sender_latitude, point.current_sender_longitude],
          [point.current_receiver_latitude, point.current_receiver_longitude]
        ], {
          color: this.getRouteColor(index),
          weight: 3,
          opacity: 0.7,
          dashArray: '5, 10' // Optional: makes the line dashed
        }).addTo(map);

        // Extend bounds to include both points
        bounds.extend([point.current_sender_latitude, point.current_sender_longitude]);
        bounds.extend([point.current_receiver_latitude, point.current_receiver_longitude]);
      }
    });

    // Fit map to show all points
    if (bounds.isValid()) {
      map.fitBounds(bounds, { padding: [50, 50] });
    }
  }

  getRouteColor(index) {
    const colors = ['#3388ff', '#ff3333', '#33cc33', '#9933cc', '#ff9900', '#00ccff', '#ff6600', '#cc33ff'];
    return colors[index % colors.length];
  }

  showError() {
    this.element.innerHTML = '<div class="alert alert-warning">Unable to display map. No valid location coordinates available.</div>';
    this.element.style.height = 'auto';
  }
}