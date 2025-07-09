import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { Application } from "@hotwired/stimulus";
import ShowTruckLoadingMapController from "controllers/show_truck_loading_map_controller";
import { waitFor } from "@testing-library/dom";

describe("ShowTruckLoadingMapController", () => {
  let application;
  let container;
  let mockLeaflet;

  async function setupNewController(html) {
    document.body.innerHTML = html;
    application.stop();
    application = Application.start();
    application.register("show-truck-loading-map", ShowTruckLoadingMapController);
    const container = document.querySelector('[data-controller="show-truck-loading-map"]');
    
    let controller;
    await waitFor(() => {
      controller = application.getControllerForElementAndIdentifier(container, "show-truck-loading-map");
      expect(controller).not.toBeNull();
    });

    return { controller, container };
  }

  beforeEach(() => {
    mockLeaflet = {
      map: vi.fn().mockReturnValue({
        setView: vi.fn().mockReturnThis(),
        addLayer: vi.fn().mockReturnThis(),
        fitBounds: vi.fn().mockReturnThis()
      }),
      tileLayer: vi.fn().mockReturnValue({
        addTo: vi.fn().mockReturnThis()
      }),
      marker: vi.fn().mockReturnValue({
        addTo: vi.fn().mockReturnThis(),
        bindPopup: vi.fn().mockReturnThis()
      }),
      polyline: vi.fn().mockReturnValue({
        addTo: vi.fn().mockReturnThis()
      }),
      latLngBounds: vi.fn().mockReturnValue({
        extend: vi.fn().mockReturnThis(),
        isValid: vi.fn().mockReturnValue(true)
      })
    };

    global.L = mockLeaflet;

    document.body.innerHTML = `
      <div 
        data-controller="show-truck-loading-map"
        data-show-truck-loading-map-shipments-json-value='[{
          "current_sender_latitude": 40.7128,
          "current_sender_longitude": -74.0060,
          "current_receiver_latitude": 34.0522,
          "current_receiver_longitude": -118.2437,
          "current_sender_address": "New York, NY",
          "current_receiver_address": "Los Angeles, CA"
        }]'>
      </div>
    `;

    application = Application.start();
    application.register("show-truck-loading-map", ShowTruckLoadingMapController);

    container = document.querySelector('[data-controller="show-truck-loading-map"]');
  });

  afterEach(() => {
    document.body.innerHTML = "";
    application.stop();
    delete global.L;
  });

  describe("connect", () => {
    it("initializes the map when valid shipments are provided", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-truck-loading-map");
      
      controller.connect();
      
      expect(mockLeaflet.map).toHaveBeenCalledWith(container);
      expect(mockLeaflet.tileLayer).toHaveBeenCalled();
      expect(mockLeaflet.marker).toHaveBeenCalled();
      expect(mockLeaflet.polyline).toHaveBeenCalled();
    });

    it("shows error when no shipments are provided", async () => {
      const { container } = await setupNewController(`
        <div 
          data-controller="show-truck-loading-map"
          data-show-truck-loading-map-shipments-json-value='[]'>
        </div>
      `);

      expect(container.innerHTML).toContain("Unable to display map");
      expect(container.style.height).toBe("auto");
    });

    it("shows error when all shipments have invalid coordinates", async () => {
      const { container } = await setupNewController(`
        <div 
          data-controller="show-truck-loading-map"
          data-show-truck-loading-map-shipments-json-value='[{
            "current_sender_latitude": 0,
            "current_sender_longitude": 0,
            "current_receiver_latitude": 0,
            "current_receiver_longitude": 0
          }]'>
        </div>
      `);

      expect(container.innerHTML).toContain("Unable to display map");
      expect(container.style.height).toBe("auto");
    });
  });

  describe("hasValidCoordinates", () => {
    it("returns true for a shipment with valid coordinates", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-truck-loading-map");
      
      const validShipment = {
        current_sender_latitude: 40.7128,
        current_sender_longitude: -74.0060,
        current_receiver_latitude: 34.0522,
        current_receiver_longitude: -118.2437
      };
      
      expect(controller.hasValidCoordinates(validShipment)).toBe(true);
    });

    it("returns false when any coordinate is missing or zero", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-truck-loading-map");

      const invalidShipment = {
        current_sender_latitude: 0,
        current_sender_longitude: -74.0060,
        current_receiver_latitude: 34.0522,
        current_receiver_longitude: -118.2437
      };

      expect(controller.hasValidCoordinates(invalidShipment)).toBe(false);
    });
  });

  describe("initMap", () => {
    it("creates markers for sender and receiver", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-truck-loading-map");

      controller.initMap();

      expect(mockLeaflet.marker).toHaveBeenCalledWith([40.7128, -74.0060]);
      expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(expect.stringContaining("New York, NY"));
      expect(mockLeaflet.marker).toHaveBeenCalledWith([34.0522, -118.2437]);
      expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(expect.stringContaining("Los Angeles, CA"));
    });

    it("draws polyline between sender and receiver", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-truck-loading-map");

      controller.initMap();

      expect(mockLeaflet.polyline).toHaveBeenCalledWith(
        [
          [40.7128, -74.0060],
          [34.0522, -118.2437]
        ],
        expect.objectContaining({ color: expect.any(String), weight: 3, opacity: 0.7 })
      );
    });

    it("fits map bounds to all points", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-truck-loading-map");

      controller.initMap();

      expect(mockLeaflet.latLngBounds).toHaveBeenCalled();
      expect(mockLeaflet.map().fitBounds).toHaveBeenCalled();
    });
  });

  describe("showError", () => {
    it("displays an error message if no valid shipments", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-truck-loading-map");

      controller.showError();

      expect(container.innerHTML).toContain("Unable to display map");
      expect(container.style.height).toBe("auto");
    });
  });
});
