import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { Application } from "@hotwired/stimulus";
import RatingModalController from "controllers/rating_modal_controller";

describe("RatingModalController", () => {
  let application;
  let container;

  beforeEach(() => {
    // Set up the DOM structure
    document.body.innerHTML = `
      <div data-controller="rating-modal">
        <div data-rating-modal-target="modal" class="modal">
          <div class="modal-content">
            <form data-rating-modal-target="form" data-action="rating-modal#submitForm">
              <div class="star-input-group">
                <label class="star-label">
                  <input type="checkbox" data-rating-modal-target="stars" data-action="rating-modal#selectStar" data-stars="1" style="display: none;">
                  <span class="star-display">☆</span>
                </label>
                <label class="star-label">
                  <input type="checkbox" data-rating-modal-target="stars" data-action="rating-modal#selectStar" data-stars="2" style="display: none;">
                  <span class="star-display">☆</span>
                </label>
                <label class="star-label">
                  <input type="checkbox" data-rating-modal-target="stars" data-action="rating-modal#selectStar" data-stars="3" style="display: none;">
                  <span class="star-display">☆</span>
                </label>
                <label class="star-label">
                  <input type="checkbox" data-rating-modal-target="stars" data-action="rating-modal#selectStar" data-stars="4" style="display: none;">
                  <span class="star-display">☆</span>
                </label>
                <label class="star-label">
                  <input type="checkbox" data-rating-modal-target="stars" data-action="rating-modal#selectStar" data-stars="5" style="display: none;">
                  <span class="star-display">☆</span>
                </label>
              </div>
              <textarea data-rating-modal-target="comment" placeholder="Share your experience..."></textarea>
              <input type="hidden" data-rating-modal-target="deliveryShipmentId">
              <input type="hidden" data-rating-modal-target="companyId">
              <button type="submit" data-rating-modal-target="submitBtn">Submit Rating</button>
              <button type="button" data-rating-modal-target="closeBtn" data-action="rating-modal#hideModal">Cancel</button>
            </form>
          </div>
        </div>
        <button data-action="rating-modal#showModal" data-delivery-shipment-id="123" data-company-id="456">Rate</button>
      </div>
    `;

    // Create a meta tag for CSRF token
    const metaTag = document.createElement("meta");
    metaTag.name = "csrf-token";
    metaTag.content = "test-csrf-token";
    document.head.appendChild(metaTag);

    // Initialize Stimulus
    application = Application.start();
    application.register("rating-modal", RatingModalController);

    // Get the container
    container = document.querySelector('[data-controller="rating-modal"]');
  });

  afterEach(() => {
    // Clean up
    document.body.innerHTML = "";
    document.head.innerHTML = "";
    application.stop();
    vi.restoreAllMocks();
  });

  describe("connect", () => {
    it("initializes with modal hidden", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");
      expect(controller.modalTarget.style.display).toBe("none");
    });
  });

  describe("showModal", () => {
    it("shows the modal and sets the delivery shipment and company IDs", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");
      const mockEvent = { preventDefault: vi.fn() };

      // Mock the event.currentTarget.dataset
      Object.defineProperty(mockEvent, 'currentTarget', {
        value: {
          dataset: {
            deliveryShipmentId: '123',
            companyId: '456'
          }
        }
      });

      controller.showModal(mockEvent);

      expect(mockEvent.preventDefault).toHaveBeenCalled();
      expect(controller.modalTarget.style.display).toBe("flex");
      expect(controller.deliveryShipmentIdTarget.value).toBe("123");
      expect(controller.companyIdTarget.value).toBe("456");
    });

    it("resets the form when showing modal", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");
      const mockEvent = { preventDefault: vi.fn() };

      // Mock the event.currentTarget.dataset
      Object.defineProperty(mockEvent, 'currentTarget', {
        value: {
          dataset: {
            deliveryShipmentId: '123',
            companyId: '456'
          }
        }
      });

      // Set some initial values
      controller.starsTargets[0].checked = true;
      controller.commentTarget.value = "Test comment";

      controller.showModal(mockEvent);

      // Check that form was reset
      expect(controller.starsTargets.every(star => !star.checked)).toBe(true);
      expect(controller.commentTarget.value).toBe("");
    });
  });

  describe("hideModal", () => {
    it("hides the modal", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");
      
      // Show modal first
      controller.modalTarget.style.display = "flex";
      
      controller.hideModal();
      
      expect(controller.modalTarget.style.display).toBe("none");
    });
  });

  describe("selectStar", () => {
    it("selects the correct number of stars", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");
      const event = { currentTarget: { dataset: { stars: "3" } } };

      controller.selectStar(event);

      // Check that first 3 stars are checked
      expect(controller.starsTargets[0].checked).toBe(true);
      expect(controller.starsTargets[1].checked).toBe(true);
      expect(controller.starsTargets[2].checked).toBe(true);
      expect(controller.starsTargets[3].checked).toBe(false);
      expect(controller.starsTargets[4].checked).toBe(false);
    });
  });

  describe("submitForm", () => {
    it("shows alert when no stars are selected", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");
      const event = { preventDefault: vi.fn() };
      const mockAlert = vi.spyOn(window, 'alert').mockImplementation(() => {});

      controller.submitForm(event);

      expect(mockAlert).toHaveBeenCalledWith('Please select a rating (1-5 stars)');
      mockAlert.mockRestore();
    });

    it("submits form with correct data when stars are selected", async () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");
      const event = { preventDefault: vi.fn() };
      
      // Set up form data
      controller.deliveryShipmentIdTarget.value = "123";
      controller.companyIdTarget.value = "456";
      controller.commentTarget.value = "Great service!";
      controller.starsTargets[0].checked = true;
      controller.starsTargets[1].checked = true;
      controller.starsTargets[2].checked = true;

      // Mock fetch
      global.fetch = vi.fn(() =>
        Promise.resolve({
          ok: true,
          status: 200,
          json: () => Promise.resolve({ success: true, message: "Rating submitted successfully" })
        })
      );

      // Mock window.location.reload
      const mockReload = vi.spyOn(window.location, 'reload').mockImplementation(() => {});

      await controller.submitForm(event);

      expect(global.fetch).toHaveBeenCalledWith('/ratings', {
        method: 'POST',
        body: expect.any(FormData),
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        }
      });

      // Check that modal is hidden and page reloads
      expect(controller.modalTarget.style.display).toBe("none");
      expect(mockReload).toHaveBeenCalled();

      global.fetch.mockRestore();
      mockReload.mockRestore();
    });

    it("shows error alert when fetch fails", async () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");
      const event = { preventDefault: vi.fn() };
      
      // Set up form data
      controller.starsTargets[0].checked = true;
      controller.commentTarget.value = "Great service!";

      // Mock fetch to fail
      global.fetch = vi.fn(() =>
        Promise.resolve({
          ok: true,
          status: 200,
          json: () => Promise.resolve({ success: false, message: "Validation failed" })
        })
      );

      const mockAlert = vi.spyOn(window, 'alert').mockImplementation(() => {});

      await controller.submitForm(event);

      expect(mockAlert).toHaveBeenCalledWith('Validation failed');

      global.fetch.mockRestore();
      mockAlert.mockRestore();
    });
  });
}); 