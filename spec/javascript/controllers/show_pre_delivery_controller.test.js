import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { Application } from "@hotwired/stimulus";
import ShowPreDeliveryController from "controllers/show_pre_delivery_controller";

describe("ShowPreDeliveryController", () => {
  let application;
  let container;

  beforeEach(() => {
    // Set up a fresh Stimulus application and container for each test
    document.body.innerHTML = `
      <div data-controller="show-pre-delivery">
        <div id="initiate-modal" class="modal hidden">
          <div class="modal-content">
            <button type="button" data-action="show-pre-delivery#close">Cancel</button>
          </div>
        </div>
        <button data-action="show-pre-delivery#open">Open Modal</button>
      </div>
    `;

    // Create a meta tag for CSRF token
    const metaTag = document.createElement("meta");
    metaTag.name = "csrf-token";
    metaTag.content = "test-csrf-token";
    document.head.appendChild(metaTag);

    // Set up the Stimulus application
    application = Application.start();
    application.register("show-pre-delivery", ShowPreDeliveryController);

    // Get the container with the controller
    container = document.querySelector('[data-controller="show-pre-delivery"]');
  });

  afterEach(() => {
    // Clean up
    document.body.innerHTML = "";
    document.head.innerHTML = "";
    application.stop();
  });

  describe("connect", () => {
    it("initializes the controller with the correct elements", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-pre-delivery");

      expect(controller.modal).toBe(document.getElementById("initiate-modal"));
    });
  });

  describe("open", () => {
    it("shows the modal", () => {
      const button = document.querySelector('[data-action="show-pre-delivery#open"]');
      const modal = document.getElementById("initiate-modal");

      // Simulate clicking the button
      button.click();

      // Check if the modal is visible
      expect(modal.classList.contains("hidden")).toBe(false);
    });
  });

  describe("close", () => {
    it("hides the modal", () => {
      const modal = document.getElementById("initiate-modal");
      const closeButton = document.querySelector('[data-action="show-pre-delivery#close"]');

      // First show the modal
      modal.classList.remove("hidden");

      // Simulate clicking the close button
      closeButton.click();

      // Check if the modal is hidden
      expect(modal.classList.contains("hidden")).toBe(true);
    });
  });
});
