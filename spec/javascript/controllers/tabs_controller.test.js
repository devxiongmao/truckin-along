import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { Application } from "@hotwired/stimulus";
import TabsController from "controllers/tabs_controller";

describe("TabsController", () => {
  let application;
  let container;

  beforeEach(() => {
    // Set up a fresh Stimulus application and container for each test
    document.body.innerHTML = `
      <div data-controller="tabs">
        <div class="tabs">
          <button data-tabs-target="tab" data-tab="content1" data-action="tabs#showTab">Tab 1</button>
          <button data-tabs-target="tab" data-tab="content2" data-action="tabs#showTab">Tab 2</button>
          <button data-tabs-target="tab" data-tab="content3" data-action="tabs#showTab">Tab 3</button>
        </div>
        <div class="contents">
          <div id="content1" data-tabs-target="content">Content 1</div>
          <div id="content2" data-tabs-target="content">Content 2</div>
          <div id="content3" data-tabs-target="content">Content 3</div>
        </div>
      </div>
    `;

    // Set up the Stimulus application
    application = Application.start();
    application.register("tabs", TabsController);

    // Get the container with the controller
    container = document.querySelector('[data-controller="tabs"]');
  });

  afterEach(() => {
    // Clean up
    document.body.innerHTML = "";
    application.stop();
  });

  describe("connect", () => {
    it("sets the first tab as active by default", () => {
      // Get references to tabs and content
      const firstTab = document.querySelector('[data-tab="content1"]');
      const firstContent = document.getElementById("content1");

      // First tab and content should have active class
      expect(firstTab.classList.contains("active")).toBe(true);
      expect(firstContent.classList.contains("active")).toBe(true);
    });

    it("does nothing when there are no tabs", () => {
      // Replace the HTML with a version that has no tabs
      document.body.innerHTML = `
        <div data-controller="tabs">
          <div class="contents">
            <div id="content1" data-tabs-target="content">Content 1</div>
          </div>
        </div>
      `;

      // Re-initialize the controller
      application = Application.start();
      application.register("tabs", TabsController);

      // This should not throw an error
      expect(() => {
        const controller = application.getControllerForElementAndIdentifier(
          document.querySelector('[data-controller="tabs"]'),
          "tabs"
        );
      }).not.toThrow();
    });
  });

  describe("showTab", () => {
    it("activates the clicked tab and corresponding content", () => {
      // Get references to tabs and content
      const tabs = document.querySelectorAll('[data-tabs-target="tab"]');
      const secondTab = tabs[1]; // Tab 2
      const contents = document.querySelectorAll('[data-tabs-target="content"]');
      
      // Click the second tab
      secondTab.click();

      // Second tab and content should have active class
      expect(secondTab.classList.contains("active")).toBe(true);
      expect(contents[1].classList.contains("active")).toBe(true);
      
      // First tab and content should not have active class
      expect(tabs[0].classList.contains("active")).toBe(false);
      expect(contents[0].classList.contains("active")).toBe(false);
    });

    it("logs an error when no matching content is found", () => {
      // Mock console.error
      const originalConsoleError = console.error;
      console.error = vi.fn();

      // Create a tab with a non-existent content reference
      const tabElement = document.createElement("button");
      tabElement.dataset.tab = "non-existent";
      tabElement.dataset.tabsTarget = "tab";
      document.querySelector(".tabs").appendChild(tabElement);
      const controller = application.getControllerForElementAndIdentifier(container, "tabs");

      // Simulate the event
      const event = { currentTarget: tabElement };
      controller.showTab(event);

      // Check if console.error was called with the right message
      expect(console.error).toHaveBeenCalledWith("No matching content for tab: non-existent");
      
      // Restore console.error
      console.error = originalConsoleError;
    });

    it("removes active class from all tabs and contents when switching tabs", () => {
      // Get references to tabs and content
      const tabs = document.querySelectorAll('[data-tabs-target="tab"]');
      const contents = document.querySelectorAll('[data-tabs-target="content"]');
      
      // First, make sure all tabs and contents have the active class
      tabs.forEach(tab => tab.classList.add("active"));
      contents.forEach(content => content.classList.add("active"));
      
      // Click the second tab
      tabs[1].click();
      
      // Only the second tab and content should have the active class
      expect(tabs[1].classList.contains("active")).toBe(true);
      expect(contents[1].classList.contains("active")).toBe(true);
      
      // The other tabs and contents should not have the active class
      expect(tabs[0].classList.contains("active")).toBe(false);
      expect(tabs[2].classList.contains("active")).toBe(false);
      expect(contents[0].classList.contains("active")).toBe(false);
      expect(contents[2].classList.contains("active")).toBe(false);
    });
  });
});