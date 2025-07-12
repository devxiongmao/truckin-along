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
            <form data-rating-modal-target="form" action="/ratings" method="post">
              <div class="star-input-group">
                ${[1, 2, 3, 4, 5].map(i => `
                  <label class="star-label" data-action="mouseover->rating-modal#hoverStar mouseout->rating-modal#resetHover click->rating-modal#selectStar">
                    <input type="checkbox" data-rating-modal-target="stars" data-stars="${i}" style="display: none;">
                    <span class="star-display">★</span>
                  </label>
                `).join('')}
              </div>
              <textarea data-rating-modal-target="comment" name="rating[comment]" placeholder="Share your experience..."></textarea>
              <input type="hidden" data-rating-modal-target="deliveryShipmentId" name="rating[delivery_shipment_id]">
              <input type="hidden" data-rating-modal-target="companyId" name="rating[company_id]">
              <button type="button" data-rating-modal-target="closeBtn" data-action="rating-modal#hideModal">Cancel</button>
              <button type="submit" data-rating-modal-target="submitBtn">Submit Rating</button>
            </form>
          </div>
        </div>
        <button data-action="rating-modal#showModal" data-delivery-shipment-id="123" data-company-id="456">Open Modal</button>
      </div>
    `;

    // Initialize Stimulus
    application = Application.start();
    application.register("rating-modal", RatingModalController);

    // Get the container
    container = document.querySelector('[data-controller="rating-modal"]');
  });

  afterEach(() => {
    // Clean up
    document.body.innerHTML = "";
    application.stop();
  });

  describe("connect", () => {
    it("initializes with modal hidden and star counts at zero", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");

      // Check initial state
      expect(controller.modalTarget.style.display).toBe("none");
      expect(controller.selectedStars).toBe(0);
      expect(controller.hoveredStars).toBe(0);
    });
  });

  describe("showModal", () => {
    it("displays the modal and sets delivery data when button is clicked", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");
      
      // Mock preventDefault
      const mockEvent = { 
        preventDefault: vi.fn(),
        currentTarget: {
          dataset: {
            deliveryShipmentId: "789",
            companyId: "321"
          }
        }
      };
      
      // Trigger the action
      controller.showModal(mockEvent);
      
      // Check if preventDefault was called
      expect(mockEvent.preventDefault).toHaveBeenCalled();
      
      // Check if modal is displayed
      expect(controller.modalTarget.style.display).toBe("flex");
      
      // Check if delivery data was set
      expect(controller.deliveryShipmentIdTarget.value).toBe("789");
      expect(controller.companyIdTarget.value).toBe("321");
      
      // Check if form was reset
      expect(controller.commentTarget.value).toBe("");
      expect(controller.selectedStars).toBe(0);
      expect(controller.hoveredStars).toBe(0);
      
      // Check if stars were unchecked
      controller.starsTargets.forEach(star => {
        expect(star.checked).toBe(false);
      });
    });
  });

  describe("hideModal", () => {
    it("hides the modal", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");

      // Set initial state
      controller.modalTarget.style.display = "flex";
      
      // Trigger the action
      controller.hideModal();
      
      // Check if modal is hidden
      expect(controller.modalTarget.style.display).toBe("none");
    });
  });

  describe("hoverStar", () => {
    it("updates hover state and star display", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");
      
      // Mock event for hovering over 3rd star
      const mockEvent = {
        currentTarget: {
          querySelector: vi.fn().mockReturnValue({
            dataset: { stars: "3" }
          })
        }
      };
      
      // Spy on updateStarDisplay
      const updateStarDisplaySpy = vi.spyOn(controller, 'updateStarDisplay');
      
      // Trigger the action
      controller.hoverStar(mockEvent);
      
      // Check if hover state was updated
      expect(controller.hoveredStars).toBe(3);
      expect(updateStarDisplaySpy).toHaveBeenCalled();
    });
  });

  describe("resetHover", () => {
    it("resets hover state and updates star display", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");
      
      // Set initial hover state
      controller.hoveredStars = 4;
      
      // Spy on updateStarDisplay
      const updateStarDisplaySpy = vi.spyOn(controller, 'updateStarDisplay');
      
      // Trigger the action
      controller.resetHover();
      
      // Check if hover state was reset
      expect(controller.hoveredStars).toBe(0);
      expect(updateStarDisplaySpy).toHaveBeenCalled();
    });
  });

  describe("selectStar", () => {
    it("updates selected stars and checks appropriate star inputs", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");
      
      // Mock event for selecting 4th star
      const mockEvent = {
        currentTarget: {
          querySelector: vi.fn().mockReturnValue({
            dataset: { stars: "4" }
          })
        }
      };
      
      // Spy on updateStarDisplay
      const updateStarDisplaySpy = vi.spyOn(controller, 'updateStarDisplay');
      
      // Trigger the action
      controller.selectStar(mockEvent);
      
      // Check if selected stars was updated
      expect(controller.selectedStars).toBe(4);
      expect(updateStarDisplaySpy).toHaveBeenCalled();
      
      // Check if appropriate stars were checked
      controller.starsTargets.forEach((star) => {
        const starValue = parseInt(star.dataset.stars);
        if (starValue <= 4) {
          expect(star.checked).toBe(true);
        } else {
          expect(star.checked).toBe(false);
        }
      });
    });
  });

  describe("updateStarDisplay", () => {
    it("adds full-star class to stars within count", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");
      
      // Set selected stars
      controller.selectedStars = 3;
      controller.hoveredStars = 0;
      
      // Trigger the action
      controller.updateStarDisplay();
      
      // Check if appropriate stars have full-star class
      controller.starsTargets.forEach((star) => {
        const starSpan = star.parentElement.querySelector('.star-display');
        const starValue = parseInt(star.dataset.stars);
        if (starValue <= 3) {
          expect(starSpan.classList.contains('full-star')).toBe(true);
        } else {
          expect(starSpan.classList.contains('full-star')).toBe(false);
        }
      });
    });

    it("prioritizes hover state over selected state", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");
      
      // Set both hover and selected states
      controller.selectedStars = 2;
      controller.hoveredStars = 4;
      
      // Trigger the action
      controller.updateStarDisplay();
      
      // Check if hover state (4) is used instead of selected state (2)
      controller.starsTargets.forEach((star) => {
        const starSpan = star.parentElement.querySelector('.star-display');
        const starValue = parseInt(star.dataset.stars);
        if (starValue <= 4) {
          expect(starSpan.classList.contains('full-star')).toBe(true);
        } else {
          expect(starSpan.classList.contains('full-star')).toBe(false);
        }
      });
    });
  });

  describe("submitForm", () => {
    it("prevents default and shows alert when no stars selected", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");
      
      // Mock event and alert
      const mockEvent = { preventDefault: vi.fn() };
      const alertSpy = vi.spyOn(window, 'alert').mockImplementation(() => {});
      
      // Mock form submission
      const mockSubmit = vi.fn();
      controller.formTarget.submit = mockSubmit;
      
      // Trigger the action with no stars selected
      controller.submitForm(mockEvent);
      
      // Check if preventDefault was called
      expect(mockEvent.preventDefault).toHaveBeenCalled();
      
      // Check if alert was shown
      expect(alertSpy).toHaveBeenCalledWith('Please select a rating (1-5 stars)');
      
      // Check if form was NOT submitted
      expect(mockSubmit).not.toHaveBeenCalled();
      
      // Clean up
      alertSpy.mockRestore();
    });

    it("creates hidden input and submits form when stars are selected", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");
      
      // Mock event
      const mockEvent = { preventDefault: vi.fn() };
      
      // Mock form submission
      const mockSubmit = vi.fn();
      controller.formTarget.submit = mockSubmit;
      
      // Set selected stars
      controller.selectedStars = 5;
      
      // Initial form state - no star rating input should exist
      expect(controller.formTarget.querySelector('input[name="rating[stars]"]')).toBe(null);
      
      // Trigger the action
      controller.submitForm(mockEvent);
      
      // Check if preventDefault was called
      expect(mockEvent.preventDefault).toHaveBeenCalled();
      
      // Check if new hidden input was added
      const starRatingInput = controller.formTarget.querySelector('input[name="rating[stars]"]');
      expect(starRatingInput).not.toBe(null);
      expect(starRatingInput.type).toBe("hidden");
      expect(starRatingInput.value).toBe("5");
      
      // Check if form was submitted
      expect(mockSubmit).toHaveBeenCalled();
    });
  });
  
  describe("integration", () => {
    it("properly handles the complete rating workflow", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");

      // Mock form submission
      const mockSubmit = vi.fn();
      controller.formTarget.submit = mockSubmit;
      
      // 1. Initially modal is hidden
      expect(controller.modalTarget.style.display).toBe("none");
      expect(controller.selectedStars).toBe(0);
      
      // 2. Open the modal
      const openButton = document.querySelector('[data-action="rating-modal#showModal"]');
      openButton.dispatchEvent(new Event("click", { bubbles: true }));
      expect(controller.modalTarget.style.display).toBe("flex");
      
      // 3. Select 4 stars
      controller.selectedStars = 4;
      controller.updateStarDisplay();
      
      // Check if 4 stars are displayed as selected
      controller.starsTargets.forEach((star) => {
        const starSpan = star.parentElement.querySelector('.star-display');
        const starValue = parseInt(star.dataset.stars);
        if (starValue <= 4) {
          expect(starSpan.classList.contains('full-star')).toBe(true);
        } else {
          expect(starSpan.classList.contains('full-star')).toBe(false);
        }
      });
      
      // 4. Add a comment
      controller.commentTarget.value = "Great delivery!";
      
      // 5. Submit the form by calling the method directly
      const mockEvent = { preventDefault: vi.fn() };
      controller.submitForm(mockEvent);
      
      // Check if form was submitted with correct star rating
      const starRatingInput = controller.formTarget.querySelector('input[name="rating[stars]"]');
      expect(starRatingInput.value).toBe("4");
      expect(mockSubmit).toHaveBeenCalled();
    });

    it("properly handles star hover interactions", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "rating-modal");

      // 1. Select 2 stars initially
      controller.selectedStars = 2;
      controller.updateStarDisplay();
      
      // 2. Hover over 4th star
      controller.hoveredStars = 4;
      controller.updateStarDisplay();
      
      // Check if 4 stars are displayed (hover overrides selection)
      controller.starsTargets.forEach((star) => {
        const starSpan = star.parentElement.querySelector('.star-display');
        const starValue = parseInt(star.dataset.stars);
        if (starValue <= 4) {
          expect(starSpan.classList.contains('full-star')).toBe(true);
        } else {
          expect(starSpan.classList.contains('full-star')).toBe(false);
        }
      });
      
      // 3. Reset hover
      controller.resetHover();
      
      // Check if display reverts to selected stars (2)
      controller.starsTargets.forEach((star) => {
        const starSpan = star.parentElement.querySelector('.star-display');
        const starValue = parseInt(star.dataset.stars);
        if (starValue <= 2) {
          expect(starSpan.classList.contains('full-star')).toBe(true);
        } else {
          expect(starSpan.classList.contains('full-star')).toBe(false);
        }
      });
    });
  });
});
