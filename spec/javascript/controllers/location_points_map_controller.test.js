import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { Application } from "@hotwired/stimulus";
import LocationPointsMapController from "controllers/location_points_map_controller";
import { waitFor } from "@testing-library/dom";

describe("LocationPointsMapController", () => {
  let application;
  let container;
  let mockLeaflet;

  async function setupNewController(html) {
    document.body.innerHTML = html;
    application.stop();
    application = Application.start();
    application.register("location-points-map", LocationPointsMapController);
    const container = document.querySelector('[data-controller="location-points-map"]');
    
    let controller;
    await waitFor(() => {
      controller = application.getControllerForElementAndIdentifier(container, "location-points-map");
      expect(controller).not.toBeNull();
    });

    return { controller, container };
  }

  beforeEach(() => {
    // Clear all mocks from previous tests
    vi.clearAllMocks();
    
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
      }),
      icon: vi.fn().mockReturnValue({})
    };

    global.L = mockLeaflet;

    document.body.innerHTML = `
      <div 
        data-controller="location-points-map"
        data-location-points-map-points-json-value='[{
          "current_sender_latitude": 40.7128,
          "current_sender_longitude": -74.0060,
          "receiver_latitude": 34.0522,
          "receiver_longitude": -118.2437,
          "current_sender_address": "New York, NY",
          "receiver_address": "Los Angeles, CA"
        }]'>
      </div>
    `;

    application = Application.start();
    application.register("location-points-map", LocationPointsMapController);

    container = document.querySelector('[data-controller="location-points-map"]');
  });

  afterEach(() => {
    document.body.innerHTML = "";
    application.stop();
    delete global.L;
  });

  describe("connect", () => {
    it("initializes the map when valid points are provided", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "location-points-map");
      
      controller.connect();
      
      expect(mockLeaflet.map).toHaveBeenCalledWith(container);
      expect(mockLeaflet.tileLayer).toHaveBeenCalledWith(
        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        expect.objectContaining({
          attribution: expect.stringContaining('OpenStreetMap')
        })
      );
      expect(mockLeaflet.marker).toHaveBeenCalled();
      expect(mockLeaflet.polyline).toHaveBeenCalled();
    });

    it("shows error when no points are provided", async () => {
      const { container } = await setupNewController(`
        <div 
          data-controller="location-points-map"
          data-location-points-map-points-json-value='[]'>
        </div>
      `);

      expect(container.innerHTML).toContain("Unable to display map");
      expect(container.innerHTML).toContain("No valid location coordinates available");
      expect(container.style.height).toBe("auto");
    });

    it("shows error when all points have invalid coordinates", async () => {
      const { container } = await setupNewController(`
        <div 
          data-controller="location-points-map"
          data-location-points-map-points-json-value='[{
            "current_sender_latitude": 0,
            "current_sender_longitude": 0,
            "receiver_latitude": 0,
            "receiver_longitude": 0
          }]'>
        </div>
      `);

      expect(container.innerHTML).toContain("Unable to display map");
      expect(container.style.height).toBe("auto");
    });

    it("shows error when points have null coordinates", async () => {
      const { container } = await setupNewController(`
        <div 
          data-controller="location-points-map"
          data-location-points-map-points-json-value='[{
            "current_sender_latitude": null,
            "current_sender_longitude": -74.0060,
            "receiver_latitude": 34.0522,
            "receiver_longitude": -118.2437
          }]'>
        </div>
      `);

      expect(container.innerHTML).toContain("Unable to display map");
    });

    it("initializes map when at least one point has valid coordinates", async () => {
      const { container } = await setupNewController(`
        <div 
          data-controller="location-points-map"
          data-location-points-map-points-json-value='[
            {
              "current_sender_latitude": 0,
              "current_sender_longitude": 0,
              "receiver_latitude": 0,
              "receiver_longitude": 0
            },
            {
              "current_sender_latitude": 40.7128,
              "current_sender_longitude": -74.0060,
              "receiver_latitude": 34.0522,
              "receiver_longitude": -118.2437
            }
          ]'>
        </div>
      `);

      expect(mockLeaflet.map).toHaveBeenCalledWith(container);
    });
  });

  describe("hasValidPoints", () => {
    it("returns true when points array has valid coordinates", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "location-points-map");
      
      expect(controller.hasValidPoints()).toBe(true);
    });

    it("returns false when points array is empty", async () => {
      const { controller } = await setupNewController(`
        <div 
          data-controller="location-points-map"
          data-location-points-map-points-json-value='[]'>
        </div>
      `);
      
      expect(controller.hasValidPoints()).toBe(false);
    });

    it("returns false when no points have valid coordinates", async () => {
      const { controller } = await setupNewController(`
        <div 
          data-controller="location-points-map"
          data-location-points-map-points-json-value='[{
            "current_sender_latitude": 0,
            "current_sender_longitude": 0,
            "receiver_latitude": 0,
            "receiver_longitude": 0
          }]'>
        </div>
      `);
      
      expect(controller.hasValidPoints()).toBe(false);
    });
  });

  describe("hasValidCoordinates", () => {
    it("returns true for a point with valid coordinates", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "location-points-map");
      
      const validPoint = {
        current_sender_latitude: 40.7128,
        current_sender_longitude: -74.0060,
        receiver_latitude: 34.0522,
        receiver_longitude: -118.2437
      };
      
      expect(controller.hasValidCoordinates(validPoint)).toBe(true);
    });

    it("returns false when any coordinate is null", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "location-points-map");

      const invalidPoint = {
        current_sender_latitude: null,
        current_sender_longitude: -74.0060,
        receiver_latitude: 34.0522,
        receiver_longitude: -118.2437
      };

      expect(controller.hasValidCoordinates(invalidPoint)).toBe(false);
    });

    it("returns false when any coordinate is zero", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "location-points-map");

      const invalidPoint = {
        current_sender_latitude: 0,
        current_sender_longitude: -74.0060,
        receiver_latitude: 34.0522,
        receiver_longitude: -118.2437
      };

      expect(controller.hasValidCoordinates(invalidPoint)).toBe(false);
    });

    it("returns false when sender coordinates are missing", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "location-points-map");

      const invalidPoint = {
        receiver_latitude: 34.0522,
        receiver_longitude: -118.2437
      };

      expect(controller.hasValidCoordinates(invalidPoint)).toBe(false);
    });

    it("returns false when receiver coordinates are missing", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "location-points-map");

      const invalidPoint = {
        current_sender_latitude: 40.7128,
        current_sender_longitude: -74.0060
      };

      expect(controller.hasValidCoordinates(invalidPoint)).toBe(false);
    });
  });

  describe("initMap", () => {
    it("creates map with correct initial view", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "location-points-map");

      controller.initMap();

      expect(mockLeaflet.map).toHaveBeenCalledWith(container);
      expect(mockLeaflet.map().setView).toHaveBeenCalledWith([0, 0], 2);
    });

    it("adds OpenStreetMap tile layer", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "location-points-map");

      controller.initMap();

      expect(mockLeaflet.tileLayer).toHaveBeenCalledWith(
        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        expect.objectContaining({
          attribution: expect.stringContaining('OpenStreetMap')
        })
      );
    });

    it("creates custom icons for start and end points", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "location-points-map");

      controller.initMap();

      expect(mockLeaflet.icon).toHaveBeenCalledWith(
        expect.objectContaining({
          iconUrl: expect.stringContaining('marker-icon-2x-red.png'),
          iconSize: [25, 41]
        })
      );
      expect(mockLeaflet.icon).toHaveBeenCalledWith(
        expect.objectContaining({
          iconUrl: expect.stringContaining('marker-icon-2x-blue.png'),
          iconSize: [25, 41]
        })
      );
    });

    it("creates markers for sender and receiver with addresses", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "location-points-map");

      controller.initMap();

      expect(mockLeaflet.marker).toHaveBeenCalledWith([40.7128, -74.0060], expect.any(Object));
      expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(
        expect.stringContaining("Start Location 1")
      );
      expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(
        expect.stringContaining("New York, NY")
      );

      expect(mockLeaflet.marker).toHaveBeenCalledWith([34.0522, -118.2437], expect.any(Object));
      expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(
        expect.stringContaining("End Location 1")
      );
      expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(
        expect.stringContaining("Los Angeles, CA")
      );
    });

    it("creates markers with coordinates when addresses are missing", async () => {
      const { controller } = await setupNewController(`
        <div 
          data-controller="location-points-map"
          data-location-points-map-points-json-value='[{
            "current_sender_latitude": 40.7128,
            "current_sender_longitude": -74.0060,
            "receiver_latitude": 34.0522,
            "receiver_longitude": -118.2437
          }]'>
        </div>
      `);

      controller.initMap();

      expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(
        expect.stringContaining("Lat: 40.7128, Lng: -74.006")
      );
      expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(
        expect.stringContaining("Lat: 34.0522, Lng: -118.2437")
      );
    });

    it("draws polyline between sender and receiver", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "location-points-map");

      controller.initMap();

      expect(mockLeaflet.polyline).toHaveBeenCalledWith(
        [
          [40.7128, -74.0060],
          [34.0522, -118.2437]
        ],
        expect.objectContaining({
          color: expect.any(String),
          weight: 3,
          opacity: 0.7,
          dashArray: '5, 10'
        })
      );
    });

    it("handles multiple points with different colors", async () => {
      // Clear mocks before this test
      vi.clearAllMocks();
      
      const { controller } = await setupNewController(`
        <div 
          data-controller="location-points-map"
          data-location-points-map-points-json-value='[
            {
              "current_sender_latitude": 40.7128,
              "current_sender_longitude": -74.0060,
              "receiver_latitude": 34.0522,
              "receiver_longitude": -118.2437
            },
            {
              "current_sender_latitude": 41.8781,
              "current_sender_longitude": -87.6298,
              "receiver_latitude": 29.7604,
              "receiver_longitude": -95.3698
            }
          ]'>
        </div>
      `);

      // Clear mocks again since setupNewController might trigger connect()
      vi.clearAllMocks();
      
      controller.initMap();

      expect(mockLeaflet.polyline).toHaveBeenCalledTimes(2);
      expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(
        expect.stringContaining("Start Location 1")
      );
      expect(mockLeaflet.marker().bindPopup).toHaveBeenCalledWith(
        expect.stringContaining("Start Location 2")
      );
    });

    it("fits map bounds to all points", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "location-points-map");

      controller.initMap();

      expect(mockLeaflet.latLngBounds).toHaveBeenCalled();
      expect(mockLeaflet.latLngBounds().extend).toHaveBeenCalledWith([40.7128, -74.0060]);
      expect(mockLeaflet.latLngBounds().extend).toHaveBeenCalledWith([34.0522, -118.2437]);
      expect(mockLeaflet.map().fitBounds).toHaveBeenCalledWith(
        expect.anything(),
        { padding: [50, 50] }
      );
    });

    it("skips points with invalid coordinates", async () => {
      // Clear mocks before this test
      vi.clearAllMocks();
      
      const { controller } = await setupNewController(`
        <div 
          data-controller="location-points-map"
          data-location-points-map-points-json-value='[
            {
              "current_sender_latitude": 0,
              "current_sender_longitude": 0,
              "receiver_latitude": 0,
              "receiver_longitude": 0
            },
            {
              "current_sender_latitude": 40.7128,
              "current_sender_longitude": -74.0060,
              "receiver_latitude": 34.0522,
              "receiver_longitude": -118.2437
            }
          ]'>
        </div>
      `);

      // Clear mocks again since setupNewController might trigger connect()
      vi.clearAllMocks();
      
      controller.initMap();

      // Should only create markers for the valid point
      expect(mockLeaflet.marker).toHaveBeenCalledTimes(2); // Start and end for valid point
      expect(mockLeaflet.polyline).toHaveBeenCalledTimes(1);
    });
  });

  describe("getRouteColor", () => {
    it("returns different colors for different indices", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "location-points-map");

      const color1 = controller.getRouteColor(0);
      const color2 = controller.getRouteColor(1);
      const color3 = controller.getRouteColor(2);

      expect(color1).toBe('#3388ff');
      expect(color2).toBe('#ff3333');
      expect(color3).toBe('#33cc33');
    });

    it("cycles through colors when index exceeds array length", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "location-points-map");

      const color1 = controller.getRouteColor(0);
      const color9 = controller.getRouteColor(8); // Should cycle back to first color

      expect(color1).toBe('#3388ff');
      expect(color9).toBe('#3388ff');
    });
  });

  describe("showError", () => {
    it("displays an error message when no valid points are available", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "location-points-map");

      controller.showError();

      expect(container.innerHTML).toContain("Unable to display map");
      expect(container.innerHTML).toContain("No valid location coordinates available");
      expect(container.innerHTML).toContain("alert alert-warning");
      expect(container.style.height).toBe("auto");
    });
  });
});