import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { Application } from "@hotwired/stimulus";
import ModalController from "controllers/create_maintenance_controller";

describe("CreateMaintenanceController", () => {
  let application;
  let container;

  beforeEach(() => {
    // Set up the DOM structure
    document.body.innerHTML = `
      <div data-controller="create-maintenance">
        <div id="maintenance-modal" class="modal hidden">
          <div class="modal-content">
            <form id="maintenance-form" data-action="create-maintenance#submitForm">
              <input type="hidden" name="truck_id" id="modal-truck-id">
              <button type="button" data-action="create-maintenance#close">Cancel</button>
            </form>
          </div>
        </div>
        <button data-action="create-maintenance#open" data-modal-truck-id-value="123">Open Modal</button>
      </div>
    `;

    // Create a meta tag for CSRF token
    const metaTag = document.createElement("meta");
    metaTag.name = "csrf-token";
    metaTag.content = "test-csrf-token";
    document.head.appendChild(metaTag);

    // Initialize Stimulus
    application = Application.start();
    application.register("create-maintenance", ModalController);

    // Get the controller
    container = document.querySelector('[data-controller="create-maintenance"]');
  });

  afterEach(() => {
    // Clean up
    document.body.innerHTML = "";
    document.head.innerHTML = "";
    application.stop();
  });

  describe("connect", () => {
    it("initializes the controller with the correct elements", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "create-maintenance");

      expect(controller.modal).toBe(document.getElementById("maintenance-modal"));
      expect(controller.form).toBe(document.getElementById("maintenance-form"));
      expect(controller.truckIdInput).toBe(document.getElementById("modal-truck-id"));
    });
  });

  describe("open", () => {
    it("shows the modal and sets the truck ID", () => {
      const button = document.querySelector('[data-action="create-maintenance#open"]');
      const modal = document.getElementById("maintenance-modal");
      const truckIdInput = document.getElementById("modal-truck-id");

      // Simulate clicking the button
      button.dispatchEvent(new Event("click", { bubbles: true }));

      // Check if the modal is visible
      expect(modal.classList.contains("hidden")).toBe(false);

      // Check if the truck ID was set correctly
      expect(truckIdInput.value).toBe("123");
    });
  });

  describe("close", () => {
    it("hides the modal when close button is clicked", () => {
      const modal = document.getElementById("maintenance-modal");
      const closeButton = document.querySelector('[data-action="create-maintenance#close"]');

      // Open modal first
      modal.classList.remove("hidden");

      // Simulate clicking the close button
      closeButton.dispatchEvent(new Event("click", { bubbles: true }));

      // Check if the modal is hidden
      expect(modal.classList.contains("hidden")).toBe(true);
    });
  });

  describe("submitForm", () => {
    it("creates and submits a form with the correct truck ID", () => {
      const form = document.getElementById("maintenance-form");
      const truckIdInput = document.getElementById("modal-truck-id");

      // Mock form submission
      const mockSubmit = vi.fn();
      vi.spyOn(HTMLFormElement.prototype, "submit").mockImplementation(mockSubmit);

      // Set truck ID
      truckIdInput.value = "456";

      // Simulate form submission
      const submitEvent = new Event("submit", { bubbles: true, cancelable: true });
      form.dispatchEvent(submitEvent);

      // Check if a new form was created with the correct action
      const createdForm = document.body.querySelector('form[action="/trucks/456/create_form?truck_id=456"]');
      expect(createdForm).not.toBeNull();

      // Check if CSRF token was added
      const csrfInput = createdForm.querySelector('input[name="authenticity_token"]');
      expect(csrfInput).not.toBeNull();
      expect(csrfInput.value).toBe("test-csrf-token");

      // Ensure form was submitted
      expect(mockSubmit).toHaveBeenCalled();
    });
  });
});
