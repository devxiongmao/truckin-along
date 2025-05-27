import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { Application } from "@hotwired/stimulus";
import CompleteDeliveryController from "controllers/complete_delivery_controller";

describe("CompleteDeliveryController", () => {
  let application;
  let container;

  beforeEach(() => {
    // Set up the DOM structure
    document.body.innerHTML = `
      <div data-controller="complete-delivery">
        <div data-complete-delivery-target="modal" class="modal">
          <div class="modal-content">
            <form data-complete-delivery-target="form">
              <div data-complete-delivery-target="odometerContainer">
                <input type="text" data-complete-delivery-target="odometerInput">
              </div>
              <button type="button" data-complete-delivery-target="confirmBtn" data-action="complete-delivery#confirmDelivery">Confirm</button>
              <button type="button" data-complete-delivery-target="cancelBtn" data-action="complete-delivery#hideModal">Cancel</button>
              <button type="button" data-action="complete-delivery#showOdometerInput">Yes</button>
              <button type="button" data-action="complete-delivery#submitWithOdometer">Submit Odometer</button>
            </form>
          </div>
        </div>
        <button data-action="complete-delivery#showModal">Open Modal</button>
      </div>
    `;

    // Initialize Stimulus
    application = Application.start();
    application.register("complete-delivery", CompleteDeliveryController);

    // Get the container
    container = document.querySelector('[data-controller="complete-delivery"]');
  });

  afterEach(() => {
    // Clean up
    document.body.innerHTML = "";
    application.stop();
  });

  describe("connect", () => {
    it("initializes with modal and odometer container hidden", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "complete-delivery");

      // Check initial state
      expect(controller.modalTarget.style.display).toBe("none");
      expect(controller.odometerContainerTarget.style.display).toBe("none");
    });
  });

  describe("showModal", () => {
    it("displays the modal when button is clicked", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "complete-delivery");
      
      // Mock preventDefault
      const mockEvent = { preventDefault: vi.fn() };
      
      // Trigger the action
      controller.showModal(mockEvent);
      
      // Check if preventDefault was called
      expect(mockEvent.preventDefault).toHaveBeenCalled();
      
      // Check if modal is displayed
      expect(controller.modalTarget.style.display).toBe("flex");
    });
  });

  describe("hideModal", () => {
    it("hides the modal and resets the odometer input", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "complete-delivery");

      // Set initial state
      controller.modalTarget.style.display = "flex";
      controller.odometerContainerTarget.style.display = "block";
      controller.odometerInputTarget.value = "12345";
      
      // Trigger the action
      controller.hideModal();
      
      // Check if modal and odometer container are hidden
      expect(controller.modalTarget.style.display).toBe("none");
      expect(controller.odometerContainerTarget.style.display).toBe("none");
      
      // Check if odometer input was reset
      expect(controller.odometerInputTarget.value).toBe("");
    });
  });

  describe("showOdometerInput", () => {
    it("shows the odometer input container when Yes button is clicked", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "complete-delivery");

      // Initial state
      controller.odometerContainerTarget.style.display = "none";
      
      // Trigger the action
      controller.showOdometerInput();
      
      // Check if odometer container is shown
      expect(controller.odometerContainerTarget.style.display).toBe("block");
    });
  });

  describe("submitWithOdometer", () => {
    it("appends the odometer reading to the form and submits it", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "complete-delivery");

      // Mock console.log to test logging
      const consoleSpy = vi.spyOn(console, "log").mockImplementation(() => {});

      // Mock form submission
      const mockSubmit = vi.fn();
      controller.formTarget.submit = mockSubmit;
      controller.odometerInputTarget.value = "54321";
      
      // Initial form state - no odometer input should exist
      expect(controller.formTarget.querySelector('input[name="odometer_reading"]')).toBe(null);
      
      // Trigger the action
      controller.submitWithOdometer();
      
      // Check if console.log was called with correct message
      expect(consoleSpy).toHaveBeenCalledWith("Submitting with odometer value:", "54321");
      
      // Check if new hidden input was added
      const odometerInput = controller.formTarget.querySelector('input[name="odometer_reading"]');
      expect(odometerInput).not.toBe(null);
      expect(odometerInput.type).toBe("hidden");
      expect(odometerInput.value).toBe("54321");
      
      // Check if form was submitted
      expect(mockSubmit).toHaveBeenCalled();
      
      // Clean up spy
      consoleSpy.mockRestore();
    });

    it("handles empty odometer input", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "complete-delivery");

      // Mock form submission
      const mockSubmit = vi.fn();
      controller.formTarget.submit = mockSubmit;
      controller.odometerInputTarget.value = "";
      
      // Trigger the action
      controller.submitWithOdometer();
      
      // Check if hidden input was still created with empty value
      const odometerInput = controller.formTarget.querySelector('input[name="odometer_reading"]');
      expect(odometerInput).not.toBe(null);
      expect(odometerInput.value).toBe("");
      
      // Check if form was submitted
      expect(mockSubmit).toHaveBeenCalled();
    });
  });
  
  describe("integration", () => {
    it("properly handles the complete workflow", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "complete-delivery");

      // Mock form submission
      const mockSubmit = vi.fn();
      controller.formTarget.submit = mockSubmit;
      
      // 1. Initially everything is hidden
      expect(controller.modalTarget.style.display).toBe("none");
      expect(controller.odometerContainerTarget.style.display).toBe("none");
      
      // 2. Open the modal
      const openButton = document.querySelector('[data-action="complete-delivery#showModal"]');
      openButton.dispatchEvent(new Event("click", { bubbles: true }));
      expect(controller.modalTarget.style.display).toBe("flex");
      
      // 3. Show odometer input
      const yesButton = document.querySelector('[data-action="complete-delivery#showOdometerInput"]');
      yesButton.dispatchEvent(new Event("click", { bubbles: true }));
      expect(controller.odometerContainerTarget.style.display).toBe("block");
      
      // 4. Enter odometer reading and submit
      controller.odometerInputTarget.value = "98765";
      const submitButton = document.querySelector('[data-action="complete-delivery#submitWithOdometer"]');
      submitButton.dispatchEvent(new Event("click", { bubbles: true }));
      
      // Check if form was submitted with correct odometer reading
      const odometerInput = controller.formTarget.querySelector('input[name="odometer_reading"]');
      expect(odometerInput.value).toBe("98765");
      expect(mockSubmit).toHaveBeenCalled();
    });

    it("properly handles hiding modal after showing odometer input", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "complete-delivery");

      // 1. Open modal and show odometer input
      controller.modalTarget.style.display = "flex";
      controller.showOdometerInput();
      controller.odometerInputTarget.value = "12345";
      
      // Verify initial state
      expect(controller.modalTarget.style.display).toBe("flex");
      expect(controller.odometerContainerTarget.style.display).toBe("block");
      expect(controller.odometerInputTarget.value).toBe("12345");
      
      // 2. Hide the modal
      controller.hideModal();
      
      // 3. Verify everything is reset
      expect(controller.modalTarget.style.display).toBe("none");
      expect(controller.odometerContainerTarget.style.display).toBe("none");
      expect(controller.odometerInputTarget.value).toBe("");
    });
  });
});