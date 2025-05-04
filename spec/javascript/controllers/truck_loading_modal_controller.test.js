import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { Application } from "@hotwired/stimulus";
import TruckLoadingModalController from "controllers/truck_loading_modal_controller";

describe("TruckLoadingModalController", () => {
  let application;
  let container;
  let controller;

  beforeEach(() => {
    // Set up the DOM structure
    document.body.innerHTML = `
      <div data-controller="truck-loading-modal">
        <div data-truck-loading-modal-target="modal" class="modal">
          <div class="modal-content">
            <form data-truck-loading-modal-target="form">
              <div data-truck-loading-modal-target="addressContainer">
                <input type="text" data-truck-loading-modal-target="addressInput">
              </div>
              <button type="button" data-truck-loading-modal-target="confirmBtn" data-action="truck-loading-modal#confirmDelivery">Confirm</button>
              <button type="button" data-truck-loading-modal-target="cancelBtn" data-action="truck-loading-modal#hideModal">Cancel</button>
              <button type="button" data-action="truck-loading-modal#showAddressInput">No</button>
              <button type="button" data-action="truck-loading-modal#submitWithAddress">Submit Address</button>
            </form>
          </div>
        </div>
        <button data-action="truck-loading-modal#showModal">Open Modal</button>
      </div>
    `;

    // Initialize Stimulus
    application = Application.start();
    application.register("truck-loading-modal", TruckLoadingModalController);

    // Get the container
    container = document.querySelector('[data-controller="truck-loading-modal"]');
  });

  afterEach(() => {
    // Clean up
    document.body.innerHTML = "";
    application.stop();
  });

  describe("connect", () => {
    it("initializes with modal and address container hidden", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "truck-loading-modal");

      // Check initial state
      expect(controller.modalTarget.style.display).toBe("none");
      expect(controller.addressContainerTarget.style.display).toBe("none");
    });
  });

  describe("showModal", () => {
    it("displays the modal when button is clicked", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "truck-loading-modal");

      const button = document.querySelector('[data-action="truck-loading-modal#showModal"]');
      
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
    it("hides the modal and resets the address input", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "truck-loading-modal");

      // Set initial state
      controller.modalTarget.style.display = "flex";
      controller.addressContainerTarget.style.display = "block";
      controller.addressInputTarget.value = "123 Test Street";
      
      // Trigger the action
      controller.hideModal();
      
      // Check if modal and address container are hidden
      expect(controller.modalTarget.style.display).toBe("none");
      expect(controller.addressContainerTarget.style.display).toBe("none");
      
      // Check if address input was reset
      expect(controller.addressInputTarget.value).toBe("");
    });
  });

  describe("confirmDelivery", () => {
    it("submits the form when confirm button is clicked", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "truck-loading-modal");

      // Mock form submission
      const mockSubmit = vi.fn();
      controller.formTarget.submit = mockSubmit;
      
      // Trigger the action
      controller.confirmDelivery();
      
      // Check if form was submitted
      expect(mockSubmit).toHaveBeenCalled();
    });
  });

  describe("showAddressInput", () => {
    it("shows the address input container when No button is clicked", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "truck-loading-modal");

      // Initial state
      controller.addressContainerTarget.style.display = "none";
      
      // Trigger the action
      controller.showAddressInput();
      
      // Check if address container is shown
      expect(controller.addressContainerTarget.style.display).toBe("block");
    });
  });

  describe("submitWithAddress", () => {
    it("appends the address to the form and submits it", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "truck-loading-modal");

      // Set up
      const mockSubmit = vi.fn();
      controller.formTarget.submit = mockSubmit;
      controller.addressInputTarget.value = "456 New Address";
      
      // Initial form state
      expect(controller.formTarget.querySelector('input[name="delivery_address"]')).toBe(null);
      
      // Trigger the action
      controller.submitWithAddress();
      
      // Check if new input was added
      const addressInput = controller.formTarget.querySelector('input[name="delivery_address"]');
      expect(addressInput).not.toBe(null);
      expect(addressInput.value).toBe("456 New Address");
      
      // Check if form was submitted
      expect(mockSubmit).toHaveBeenCalled();
    });
  });
  
  describe("integration", () => {
    it("properly handles the complete workflow", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "truck-loading-modal");

      // Mock form submission
      const mockSubmit = vi.fn();
      controller.formTarget.submit = mockSubmit;
      
      // 1. Initially everything is hidden
      expect(controller.modalTarget.style.display).toBe("none");
      expect(controller.addressContainerTarget.style.display).toBe("none");
      
      // 2. Open the modal
      const openButton = document.querySelector('[data-action="truck-loading-modal#showModal"]');
      openButton.dispatchEvent(new Event("click", { bubbles: true }));
      expect(controller.modalTarget.style.display).toBe("flex");
      
      // 3. Show address input
      const noButton = document.querySelector('[data-action="truck-loading-modal#showAddressInput"]');
      noButton.dispatchEvent(new Event("click", { bubbles: true }));
      expect(controller.addressContainerTarget.style.display).toBe("block");
      
      // 4. Enter address and submit
      controller.addressInputTarget.value = "789 Test Boulevard";
      const submitButton = document.querySelector('[data-action="truck-loading-modal#submitWithAddress"]');
      submitButton.dispatchEvent(new Event("click", { bubbles: true }));
      
      // Check if form was submitted with correct address
      const addressInput = controller.formTarget.querySelector('input[name="delivery_address"]');
      expect(addressInput.value).toBe("789 Test Boulevard");
      expect(mockSubmit).toHaveBeenCalled();
    });
  });
});