import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { Application } from "@hotwired/stimulus";
import ShowFormsController from "controllers/show_forms_controller";

describe("ShowFormsController", () => {
  let application;
  let container;

  beforeEach(() => {
    // Set up the DOM structure
    document.body.innerHTML = `
      <div data-controller="show-forms">
        <div id="form-modal" class="modal hidden">
          <div class="modal-content">
            <div id="modal-body"></div>
            <button class="close" data-action="show-forms#close">Close</button>
          </div>
        </div>
        <button data-action="show-forms#open" data-form-id="42">Open Form</button>
      </div>
    `;

    // Initialize Stimulus
    application = Application.start();
    application.register("show-forms", ShowFormsController);

    // Get the controller
    container = document.querySelector('[data-controller="show-forms"]');
  });

  afterEach(() => {
    // Clean up
    document.body.innerHTML = "";
    application.stop();
    vi.restoreAllMocks();
  });

  describe("connect", () => {
    it("initializes the modal and elements correctly", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "show-forms");
    
      expect(controller.modal).toBe(document.getElementById("form-modal"));
      expect(controller.modalBody).toBe(document.getElementById("modal-body"));
      expect(controller.closeBtn).toBe(document.querySelector(".close"));
    });
  });

  describe("open", () => {
    it("fetches and displays the form modal", async () => {
      global.fetch = vi.fn(() =>
        Promise.resolve({
          text: () => Promise.resolve("<form>Test Form</form>"),
        })
      );
      const controller = application.getControllerForElementAndIdentifier(container, "show-forms");

      const button = document.querySelector('[data-action="show-forms#open"]');
      const modal = document.getElementById("form-modal");

      // Simulate clicking the button
      button.dispatchEvent(new Event("click", { bubbles: true }));

      // Wait for the fetch promise to resolve
      await flushPromises();

      // Check if the modal content was updated
      expect(controller.modalBody.innerHTML).toBe("<form>Test Form</form>");

      // Check if the modal is visible
      expect(modal.classList.contains("hidden")).toBe(false);
    });

    it("displays an error message if the fetch request fails", async () => {
      global.fetch = vi.fn(() => Promise.reject(new Error("Network error")));
      const controller = application.getControllerForElementAndIdentifier(container, "show-forms");

      const button = document.querySelector('[data-action="show-forms#open"]');
      const modal = document.getElementById("form-modal");

      // Simulate clicking the button
      button.dispatchEvent(new Event("click", { bubbles: true }));

      // Wait for the fetch promise to reject
      await flushPromises();

      // Check if an error message was displayed
      expect(controller.modalBody.innerHTML).toContain("Error loading form");

      // Check if the modal is visible
      expect(modal.classList.contains("hidden")).toBe(false);
    });
  });

  describe("close", () => {
    it("hides the modal when close button is clicked", () => {
      const modal = document.getElementById("form-modal");
      const closeButton = document.querySelector(".close");

      // Open the modal first
      modal.classList.remove("hidden");

      // Simulate clicking the close button
      closeButton.dispatchEvent(new Event("click", { bubbles: true }));
      
      // Check if the modal is hidden
      expect(modal.classList.contains("hidden")).toBe(true);
    });
  });
});

// Helper function to flush promises
function flushPromises() {
  return new Promise(resolve => setTimeout(resolve, 0));
}