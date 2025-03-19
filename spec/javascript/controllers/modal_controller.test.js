import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { Application } from "@hotwired/stimulus";
import ModalController from "controllers/modal_controller";

describe("ModalController", () => {
  let application;
  let container;

  beforeEach(() => {
    // Set up a fresh Stimulus application and container for each test
    document.body.innerHTML = `
      <div data-controller="modal">
        <div id="initiate-modal" class="modal hidden">
          <div class="modal-content">
            <form id="initiate-form" data-action="modal#submitForm">
              <input type="hidden" name="truck_id" id="modal-truck-id">
              <button type="button" data-action="modal#close">Cancel</button>
            </form>
          </div>
        </div>
        <button data-action="modal#open" data-modal-truck-id-value="123">Open Modal</button>
      </div>
    `;

    // Create a meta tag for CSRF token
    const metaTag = document.createElement("meta");
    metaTag.name = "csrf-token";
    metaTag.content = "test-csrf-token";
    document.head.appendChild(metaTag);

    // Set up the Stimulus application
    application = Application.start();
    application.register("modal", ModalController);

    // Get the container with the controller
    container = document.querySelector('[data-controller="modal"]');
  });

  afterEach(() => {
    // Clean up
    document.body.innerHTML = "";
    document.head.innerHTML = "";
    application.stop();
  });

  describe("connect", () => {
    it("initializes the controller with the correct elements", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "modal");

      expect(controller.modal).toBe(document.getElementById("initiate-modal"));
      expect(controller.form).toBe(document.getElementById("initiate-form"));
      expect(controller.truckIdInput).toBe(document.getElementById("modal-truck-id"));
    });
  });

  describe("open", () => {
    it("shows the modal and sets the truck ID", () => {
      const button = document.querySelector('[data-action="modal#open"]');
      const modal = document.getElementById("initiate-modal");
      const truckIdInput = document.getElementById("modal-truck-id");

      // Simulate clicking the button
      button.click();

      // Check if the modal is visible
      expect(modal.classList.contains("hidden")).toBe(false);

      // Check if the truck ID was set
      expect(truckIdInput.value).toBe("123");
    });
  });

  describe("close", () => {
    it("hides the modal", () => {
      const modal = document.getElementById("initiate-modal");
      const closeButton = document.querySelector('[data-action="modal#close"]');

      // First show the modal
      modal.classList.remove("hidden");

      // Simulate clicking the close button
      closeButton.click();

      // Check if the modal is hidden
      expect(modal.classList.contains("hidden")).toBe(true);
    });
  });

  describe("submitForm", () => {
    it("creates and submits a form with the correct truck ID", () => {
      const form = document.getElementById("initiate-form");
      const truckIdInput = document.getElementById("modal-truck-id");

      // Mock form submission
      const mockSubmit = vi.fn();
      vi.spyOn(HTMLFormElement.prototype, "submit").mockImplementation(mockSubmit);

      // Set the truck ID
      truckIdInput.value = "456";

      // Simulate form submission
      const submitEvent = new Event("submit");
      form.dispatchEvent(submitEvent);

      // Check if form was created with correct action
      const createdForm = document.body.querySelector('form[action="/shipments/initiate_delivery?truck_id=456"]');
      expect(createdForm).not.toBeNull();

      // Check if CSRF token was added
      const csrfInput = createdForm.querySelector('input[name="authenticity_token"]');
      expect(csrfInput).not.toBeNull();
      expect(csrfInput.value).toBe("test-csrf-token");

      // Check if form was submitted
      expect(mockSubmit).toHaveBeenCalled();
    });
  });
});
