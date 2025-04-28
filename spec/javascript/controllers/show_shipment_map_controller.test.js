import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { Application } from "@hotwired/stimulus";
import MapController from "controllers/show_shipment_map_controller";

describe("MapController", () => {
  let application;
  let container;
  let mockLeaflet;

  beforeEach(() => {
    // Mock Leaflet library
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
      latLngBounds: vi.fn().mockReturnValue("mockBounds")
    };

    // Assign mock to global L object expected by the controller
    global.L = mockLeaflet;

    // Set up a fresh Stimulus application
    application = Application.start();
    application.register("show-shipment-map", MapController);

    // Set up default HTML structure
    document.body.innerHTML = `
      <div 
        data-controller="show-shipment-map"
        data-show-shipment-map-sender-lat-value="40.7128"
        data-show-shipment-map-sender-lng-value="-74.0060"
        data-show-shipment-map-receiver-lat-value="34.0522"
        data-show-shipment-map-receiver-lng-value="-118.2437"
        data-show-shipment-map-sender-address-value="New York, NY"
        data-show-shipment-map-receiver-address-value="Los Angeles, CA">
      </div>
    `;

    // Get the container with the controller
    container = document.querySelector('[data-controller="show-shipment-map"]');
  });

  afterEach(() => {
    // Clean up
    document.body.innerHTML = "";
    application.stop();
    delete global.L;
  });

  describe("connect", () => {
    it("initializes the map when valid coordinates are provided", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-shipment-map");
      
      // Explicitly call connect to ensure initMap is called
      controller.connect();
      
      // Check if the map was initialized with the correct center point
      const expectedCenterLat = (40.7128 + 34.0522) / 2;
      const expectedCenterLng = (-74.0060 + -118.2437) / 2;
      
      expect(mockLeaflet.map).toHaveBeenCalledWith(container);
      expect(mockLeaflet.map().setView).toHaveBeenCalledWith([expectedCenterLat, expectedCenterLng], 10);
    });

    it("shows error message when coordinates are missing", () => {
      // Clear the body and set up container without coordinates
      document.body.innerHTML = `
        <div data-controller="show-shipment-map"></div>
      `;
      
      // Need to stop and restart application to handle the new DOM elements
      application.stop();
      application = Application.start();
      application.register("show-shipment-map", MapController);
      
      const incompleteContainer = document.querySelector('[data-controller="show-shipment-map"]');
      
      // Connect event will be triggered automatically, but we need to wait for it
      // Force a connect by accessing the controller
      const controller = application.getControllerForElementAndIdentifier(incompleteContainer, "show-shipment-map");
      
      // Delay slightly to allow the connect method to complete
      setTimeout(() => {
        expect(incompleteContainer.innerHTML).toContain("Unable to display map");
        expect(incompleteContainer.style.height).toBe("auto");
      }, 0);
    });

    it("shows error message when coordinates are zero", () => {
      // Clear the body and set up container with zero coordinates
      document.body.innerHTML = `
        <div 
          data-controller="show-shipment-map"
          data-show-shipment-map-sender-lat-value="0"
          data-show-shipment-map-sender-lng-value="0"
          data-show-shipment-map-receiver-lat-value="34.0522"
          data-show-shipment-map-receiver-lng-value="-118.2437">
        </div>
      `;
      
      // Need to stop and restart application to handle the new DOM elements
      application.stop();
      application = Application.start();
      application.register("show-shipment-map", MapController);
      
      const incompleteContainer = document.querySelector('[data-controller="show-shipment-map"]');
      
      // Force a connect by accessing the controller
      const controller = application.getControllerForElementAndIdentifier(incompleteContainer, "show-shipment-map");
      
      // Call connect explicitly
      controller.connect();
      
      expect(incompleteContainer.innerHTML).toContain("Unable to display map");
    });
  });

  describe("hasValidCoordinates", () => {
    it("returns true when all coordinates are valid", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-shipment-map");
      
      expect(controller.hasValidCoordinates()).toBe(true);
    });

    it("returns false when any coordinate is missing", () => {
      // Clear the body and set up new container
      document.body.innerHTML = `
        <div 
          data-controller="show-shipment-map"
          data-show-shipment-map-sender-lat-value="40.7128"
          data-show-shipment-map-sender-lng-value="-74.0060">
        </div>
      `;
      
      // Need to stop and restart application to handle the new DOM elements
      application.stop();
      application = Application.start();
      application.register("show-shipment-map", MapController);
      
      const incompleteContainer = document.querySelector('[data-controller="show-shipment-map"]');
      const controller = application.getControllerForElementAndIdentifier(incompleteContainer, "show-shipment-map");
      
      expect(controller.hasValidCoordinates()).toBe(false);
    });

    it("returns false when any coordinate is zero", () => {
      // Clear the body and set up new container
      document.body.innerHTML = `
        <div 
          data-controller="show-shipment-map"
          data-show-shipment-map-sender-lat-value="40.7128"
          data-show-shipment-map-sender-lng-value="0"
          data-show-shipment-map-receiver-lat-value="34.0522"
          data-show-shipment-map-receiver-lng-value="-118.2437">
        </div>
      `;
      
      // Need to stop and restart application to handle the new DOM elements
      application.stop();
      application = Application.start();
      application.register("show-shipment-map", MapController);
      
      const incompleteContainer = document.querySelector('[data-controller="show-shipment-map"]');
      const controller = application.getControllerForElementAndIdentifier(incompleteContainer, "show-shipment-map");
      
      expect(controller.hasValidCoordinates()).toBe(false);
    });
  });

  describe("initMap", () => {
    it("creates a map with the correct center point", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-shipment-map");
      
      controller.initMap();
      
      const expectedCenterLat = (40.7128 + 34.0522) / 2;
      const expectedCenterLng = (-74.0060 + -118.2437) / 2;
      
      expect(mockLeaflet.map).toHaveBeenCalledWith(container);
      expect(mockLeaflet.map().setView).toHaveBeenCalledWith([expectedCenterLat, expectedCenterLng], 10);
    });

    it("adds tile layer to the map", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-shipment-map");
      
      controller.initMap();
      
      expect(mockLeaflet.tileLayer).toHaveBeenCalledWith(
        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        expect.objectContaining({
          attribution: expect.stringContaining('OpenStreetMap')
        })
      );
      expect(mockLeaflet.tileLayer().addTo).toHaveBeenCalled();
    });

    it("adds markers for sender and receiver locations", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-shipment-map");
      
      controller.initMap();
      
      // Check sender marker
      expect(mockLeaflet.marker).toHaveBeenCalledWith([40.7128, -74.0060]);
      expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(
        expect.stringContaining("New York, NY")
      );
      
      // Check receiver marker
      expect(mockLeaflet.marker).toHaveBeenCalledWith([34.0522, -118.2437]);
      expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(
        expect.stringContaining("Los Angeles, CA")
      );
    });

    it("fits the map bounds to show both markers", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-shipment-map");
      
      controller.initMap();
      
      expect(mockLeaflet.latLngBounds).toHaveBeenCalledWith([
        [40.7128, -74.0060],
        [34.0522, -118.2437]
      ]);
      expect(mockLeaflet.map().fitBounds).toHaveBeenCalledWith("mockBounds", { padding: [50, 50] });
    });
  });

  describe("showError", () => {
    it("displays error message in the container", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-shipment-map");
      
      controller.showError();
      
      expect(container.innerHTML).toContain("Unable to display map");
      expect(container.innerHTML).toContain("alert-warning");
      expect(container.style.height).toBe("auto");
    });
  });
});