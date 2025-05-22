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
      polyline: vi.fn().mockReturnValue({
        addTo: vi.fn().mockReturnThis()
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

    it("draws the main route polyline in blue", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-shipment-map");

      controller.initMap();

      expect(mockLeaflet.polyline).toHaveBeenCalledWith([
        [40.7128, -74.0060],
        [34.0522, -118.2437]
      ], { color: 'blue', weight: 3 });
      expect(mockLeaflet.polyline().addTo).toHaveBeenCalled();
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

    describe("with additional coordinates", () => {
      it("adds markers and polylines for additional coordinate segments", async () => {
        const additionalCoordinates = [
          {
            senderLat: 41.8781,
            senderLng: -87.6298,
            receiverLat: 39.7392,
            receiverLng: -104.9903,
            senderAddress: "Chicago, IL",
            receiverAddress: "Denver, CO"
          }
        ];

        const { controller } = await setupNewController(`
          <div 
            data-controller="show-shipment-map"
            data-show-shipment-map-sender-lat-value="40.7128"
            data-show-shipment-map-sender-lng-value="-74.0060"
            data-show-shipment-map-receiver-lat-value="34.0522"
            data-show-shipment-map-receiver-lng-value="-118.2437"
            data-show-shipment-map-sender-address-value="New York, NY"
            data-show-shipment-map-receiver-address-value="Los Angeles, CA"
            data-show-shipment-map-additional-coordinates-value='${JSON.stringify(additionalCoordinates)}'>
          </div>
        `);

        controller.initMap();

        // Check that additional markers were added
        expect(mockLeaflet.marker).toHaveBeenCalledWith([41.8781, -87.6298]);
        expect(mockLeaflet.marker).toHaveBeenCalledWith([39.7392, -104.9903]);

        // Check that waypoint popups were bound
        expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(expect.stringContaining("Waypoint 1"));
        expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(expect.stringContaining("Chicago, IL"));
        expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(expect.stringContaining("Waypoint 2"));
        expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(expect.stringContaining("Denver, CO"));

        // Check that additional polyline was drawn in red
        expect(mockLeaflet.polyline).toHaveBeenCalledWith([
          [41.8781, -87.6298],
          [39.7392, -104.9903]
        ], { color: 'red', weight: 2 });

        // Check that bounds include additional coordinates
        expect(mockLeaflet.latLngBounds).toHaveBeenCalledWith([
          [40.7128, -74.0060],  // main sender
          [34.0522, -118.2437], // main receiver
          [41.8781, -87.6298],  // additional sender
          [39.7392, -104.9903]  // additional receiver
        ]);
      });

      it("handles multiple additional coordinate segments", async () => {
        const additionalCoordinates = [
          {
            senderLat: 41.8781,
            senderLng: -87.6298,
            receiverLat: 39.7392,
            receiverLng: -104.9903,
            senderAddress: "Chicago, IL",
            receiverAddress: "Denver, CO"
          },
          {
            senderLat: 47.6062,
            senderLng: -122.3321,
            receiverLat: 45.5152,
            receiverLng: -122.6784,
            senderAddress: "Seattle, WA",
            receiverAddress: "Portland, OR"
          }
        ];

        const { controller } = await setupNewController(`
          <div 
            data-controller="show-shipment-map"
            data-show-shipment-map-sender-lat-value="40.7128"
            data-show-shipment-map-sender-lng-value="-74.0060"
            data-show-shipment-map-receiver-lat-value="34.0522"
            data-show-shipment-map-receiver-lng-value="-118.2437"
            data-show-shipment-map-sender-address-value="New York, NY"
            data-show-shipment-map-receiver-address-value="Los Angeles, CA"
            data-show-shipment-map-additional-coordinates-value='${JSON.stringify(additionalCoordinates)}'>
          </div>
        `);

        controller.initMap();

        // Should have 6 markers total (2 main + 4 additional)
        expect(mockLeaflet.marker).toHaveBeenCalledTimes(6);

        // Should have 3 polylines total (1 main + 2 additional)
        expect(mockLeaflet.polyline).toHaveBeenCalledTimes(3);

        // Check waypoint numbering
        expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(expect.stringContaining("Waypoint 1"));
        expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(expect.stringContaining("Waypoint 2"));
        expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(expect.stringContaining("Waypoint 3"));
        expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(expect.stringContaining("Waypoint 4"));
      });

      it("skips invalid additional coordinates", async () => {
        const additionalCoordinates = [
          {
            senderLat: 0,  // Invalid - zero coordinate
            senderLng: -87.6298,
            receiverLat: 39.7392,
            receiverLng: -104.9903,
            senderAddress: "Chicago, IL",
            receiverAddress: "Denver, CO"
          },
          {
            senderLat: 47.6062,
            senderLng: -122.3321,
            receiverLat: 45.5152,
            receiverLng: -122.6784,
            senderAddress: "Seattle, WA",
            receiverAddress: "Portland, OR"
          }
        ];

        const { controller } = await setupNewController(`
          <div 
            data-controller="show-shipment-map"
            data-show-shipment-map-sender-lat-value="40.7128"
            data-show-shipment-map-sender-lng-value="-74.0060"
            data-show-shipment-map-receiver-lat-value="34.0522"
            data-show-shipment-map-receiver-lng-value="-118.2437"
            data-show-shipment-map-sender-address-value="New York, NY"
            data-show-shipment-map-receiver-address-value="Los Angeles, CA"
            data-show-shipment-map-additional-coordinates-value='${JSON.stringify(additionalCoordinates)}'>
          </div>
        `);

        controller.initMap();

        // Should only process the valid segment (4 markers total: 2 main + 2 from valid segment)
        expect(mockLeaflet.marker).toHaveBeenCalledTimes(4);
        expect(mockLeaflet.polyline).toHaveBeenCalledTimes(2); // 1 main + 1 valid additional

        // Should not include invalid coordinates in bounds
        expect(mockLeaflet.latLngBounds).toHaveBeenCalledWith([
          [40.7128, -74.0060],  // main sender
          [34.0522, -118.2437], // main receiver
          [47.6062, -122.3321], // valid additional sender
          [45.5152, -122.6784]  // valid additional receiver
        ]);
      });
    });
  });

  describe("isValidAdditionalCoordinate", () => {
    let controller;

    beforeEach(() => {
      controller = application.getControllerForElementAndIdentifier(container, "show-shipment-map");
    });

    it("returns true for valid coordinates", () => {
      const validCoord = {
        senderLat: 41.8781,
        senderLng: -87.6298,
        receiverLat: 39.7392,
        receiverLng: -104.9903,
        senderAddress: "Chicago, IL",
        receiverAddress: "Denver, CO"
      };

      expect(controller.isValidAdditionalCoordinate(validCoord)).toBe(true);
    });

    it("returns false for null or undefined coordinates", () => {
      expect(controller.isValidAdditionalCoordinate(null)).toBe(false);
      expect(controller.isValidAdditionalCoordinate(undefined)).toBe(false);
    });

    it("returns false when any coordinate is zero", () => {
      const coordWithZero = {
        senderLat: 0,
        senderLng: -87.6298,
        receiverLat: 39.7392,
        receiverLng: -104.9903,
        senderAddress: "Chicago, IL",
        receiverAddress: "Denver, CO"
      };

      expect(controller.isValidAdditionalCoordinate(coordWithZero)).toBe(false);
    });

    it("returns false when any coordinate is not a number", () => {
      const coordWithString = {
        senderLat: "invalid",
        senderLng: -87.6298,
        receiverLat: 39.7392,
        receiverLng: -104.9903,
        senderAddress: "Chicago, IL",
        receiverAddress: "Denver, CO"
      };

      expect(controller.isValidAdditionalCoordinate(coordWithString)).toBe(false);
    });

    it("returns false when coordinates are missing", () => {
      const incompleteCoord = {
        senderLat: 41.8781,
        senderLng: -87.6298,
        // missing receiverLat and receiverLng
        senderAddress: "Chicago, IL",
        receiverAddress: "Denver, CO"
      };

      expect(controller.isValidAdditionalCoordinate(incompleteCoord)).toBe(false);
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