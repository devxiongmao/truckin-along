import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { Application } from "@hotwired/stimulus";
import ShipmentShowMapController from "controllers/show_shipment_map_controller";
import { waitFor } from "@testing-library/dom";

describe("ShipmentShowMapController", () => {
  let application;
  let container;
  let mockLeaflet;

  async function setupNewController(html) {
    document.body.innerHTML = html;
    application.stop();
    application = Application.start();
    application.register("show-shipment-map", ShipmentShowMapController);
    const container = document.querySelector('[data-controller="show-shipment-map"]');
    
    let controller;
    await waitFor(() => {
      controller = application.getControllerForElementAndIdentifier(container, "show-shipment-map");
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
      latLngBounds: vi.fn().mockReturnValue("mockBounds")
    };

    global.L = mockLeaflet;

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

    application = Application.start();
    application.register("show-shipment-map", ShipmentShowMapController);

    container = document.querySelector('[data-controller="show-shipment-map"]');
  });

  afterEach(() => {
    document.body.innerHTML = "";
    application.stop();
    delete global.L;
  });

  describe("connect", () => {
    it("initializes the map when valid coordinates are provided", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-shipment-map");
      
      controller.connect();
      
      const expectedCenterLat = (40.7128 + 34.0522) / 2;
      const expectedCenterLng = (-74.0060 + -118.2437) / 2;
      
      expect(mockLeaflet.map).toHaveBeenCalledWith(container);
      expect(mockLeaflet.map().setView).toHaveBeenCalledWith([expectedCenterLat, expectedCenterLng], 10);
    });

    it("shows error message when coordinates are missing", async () => {
      const { container } = await setupNewController(`
        <div data-controller="show-shipment-map"></div>
      `);

      expect(container.innerHTML).toContain("Unable to display map");
      expect(container.style.height).toBe("auto");
    });

    it("shows error message when coordinates are zero", async () => {
      const { container } = await setupNewController(`
        <div 
          data-controller="show-shipment-map"
          data-show-shipment-map-sender-lat-value="0"
          data-show-shipment-map-sender-lng-value="0"
          data-show-shipment-map-receiver-lat-value="34.0522"
          data-show-shipment-map-receiver-lng-value="-118.2437">
        </div>
      `);

      expect(container.innerHTML).toContain("Unable to display map");
      expect(container.style.height).toBe("auto");
    });
  });

  describe("hasValidCoordinates", () => {
    it("returns true when all coordinates are valid", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-shipment-map");
      expect(controller.hasValidCoordinates()).toBe(true);
    });

    it("returns false when any coordinate is missing", async () => {
      const { controller } = await setupNewController(`
        <div 
          data-controller="show-shipment-map"
          data-show-shipment-map-sender-lat-value="40.7128"
          data-show-shipment-map-sender-lng-value="-74.0060">
        </div>
      `);

      expect(controller.hasValidCoordinates()).toBe(false);
    });

    it("returns false when any coordinate is zero", async () => {
      const { controller } = await setupNewController(`
        <div 
          data-controller="show-shipment-map"
          data-show-shipment-map-sender-lat-value="40.7128"
          data-show-shipment-map-sender-lng-value="0"
          data-show-shipment-map-receiver-lat-value="34.0522"
          data-show-shipment-map-receiver-lng-value="-118.2437">
        </div>
      `);

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

      expect(mockLeaflet.marker).toHaveBeenCalledWith([40.7128, -74.0060]);
      expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(expect.stringContaining("New York, NY"));

      expect(mockLeaflet.marker).toHaveBeenCalledWith([34.0522, -118.2437]);
      expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(expect.stringContaining("Los Angeles, CA"));
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
