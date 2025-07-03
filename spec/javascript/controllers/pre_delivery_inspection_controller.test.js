import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { Application } from "@hotwired/stimulus";
import CheckboxController from "controllers/pre_delivery_inspection_controller";

describe("CheckboxController", () => {
  let application;
  let container;

  beforeEach(() => {
    // Set up a fresh Stimulus application and container for each test
    document.body.innerHTML = `
      <div data-controller="checkbox">
        <form id="initiate-form">
          <!-- Development mode: Check all button -->
          <button id="check-all-dev" type="button">Check All (Dev)</button>
          
          <!-- Production mode: Section-specific buttons -->
          <button class="section-check-all" data-section="users" type="button">Check All Users</button>
          <button class="section-check-all" data-section="orders" type="button">Check All Orders</button>
          <button class="section-check-all" data-section="products" type="button">Check All Products</button>
          
          <!-- Checkboxes for different sections -->
          <div class="users-checks">
            <input type="checkbox" name="user_1" value="1">
            <input type="checkbox" name="user_2" value="2">
            <input type="checkbox" name="user_3" value="3">
          </div>
          
          <div class="orders-checks">
            <input type="checkbox" name="order_1" value="1">
            <input type="checkbox" name="order_2" value="2">
          </div>
          
          <div class="products-checks">
            <input type="checkbox" name="product_1" value="1">
            <input type="checkbox" name="product_2" value="2">
            <input type="checkbox" name="product_3" value="3">
            <input type="checkbox" name="product_4" value="4">
          </div>
          
          <!-- Additional checkboxes outside sections -->
          <input type="checkbox" name="misc_1" value="1">
          <input type="checkbox" name="misc_2" value="2">
        </form>
      </div>
    `;

    // Set up the Stimulus application
    application = Application.start();
    application.register("checkbox", CheckboxController);

    // Get the container with the controller
    container = document.querySelector('[data-controller="checkbox"]');
  });

  afterEach(() => {
    // Clean up
    document.body.innerHTML = "";
    application.stop();
  });

  describe("connect", () => {
    it("sets up event listeners for development check-all button when present", () => {
      const checkAllDevBtn = document.getElementById('check-all-dev');
      const controller = application.getControllerForElementAndIdentifier(container, "checkbox");
      
      // Verify the button exists and controller has reference to it
      expect(checkAllDevBtn).toBeTruthy();
      expect(controller.checkAllDevBtn).toBe(checkAllDevBtn);
    });

    it("sets up event listeners for section check-all buttons", () => {
      const sectionButtons = document.querySelectorAll('.section-check-all');
      const controller = application.getControllerForElementAndIdentifier(container, "checkbox");
      
      // Verify section buttons exist and controller has references to them
      expect(sectionButtons.length).toBe(3);
      expect(controller.sectionButtons.length).toBe(3);
    });

    it("handles missing check-all-dev button gracefully", () => {
      // Replace HTML without the dev button
      document.body.innerHTML = `
        <div data-controller="checkbox">
          <form id="initiate-form">
            <button class="section-check-all" data-section="users" type="button">Check All Users</button>
            <div class="users-checks">
              <input type="checkbox" name="user_1" value="1">
            </div>
          </form>
        </div>
      `;

      // Re-initialize the controller
      application = Application.start();
      application.register("checkbox", CheckboxController);

      // This should not throw an error
      expect(() => {
        application.getControllerForElementAndIdentifier(
          document.querySelector('[data-controller="checkbox"]'),
          "checkbox"
        );
      }).not.toThrow();
    });
  });

  describe("disconnect", () => {
    it("removes event listeners when controller is disconnected", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "checkbox");
      const checkAllDevBtn = document.getElementById('check-all-dev');
      const sectionButtons = document.querySelectorAll('.section-check-all');

      // Spy on removeEventListener
      const devBtnSpy = vi.spyOn(checkAllDevBtn, 'removeEventListener');
      const sectionBtnSpies = Array.from(sectionButtons).map(btn => 
        vi.spyOn(btn, 'removeEventListener')
      );

      // Disconnect the controller
      controller.disconnect();

      // Verify removeEventListener was called
      expect(devBtnSpy).toHaveBeenCalledWith('click', expect.any(Function));
      sectionBtnSpies.forEach(spy => {
        expect(spy).toHaveBeenCalledWith('click', expect.any(Function));
      });
    });

    it("handles missing check-all-dev button gracefully during disconnect", () => {
      // Start with a controller that has the dev button
      const controller = application.getControllerForElementAndIdentifier(container, "checkbox");
      
      // Remove the dev button from DOM
      const devBtn = document.getElementById('check-all-dev');
      devBtn.remove();
      
      // Set the controller's reference to null (simulating what would happen)
      controller.checkAllDevBtn = null;

      // This should not throw an error
      expect(() => {
        controller.disconnect();
      }).not.toThrow();
    });
  });

  describe("checkAllDev", () => {
    it("checks all checkboxes within the initiate-form", () => {
      const checkAllDevBtn = document.getElementById('check-all-dev');
      const allCheckboxes = document.querySelectorAll('#initiate-form input[type="checkbox"]');
      
      // Ensure all checkboxes start unchecked
      allCheckboxes.forEach(checkbox => {
        checkbox.checked = false;
      });

      // Click the check-all-dev button
      checkAllDevBtn.click();

      // All checkboxes should now be checked
      allCheckboxes.forEach(checkbox => {
        expect(checkbox.checked).toBe(true);
      });
    });

    it("prevents default behavior on the event", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "checkbox");
      const mockEvent = {
        preventDefault: vi.fn(),
        currentTarget: document.getElementById('check-all-dev')
      };

      controller.checkAllDev(mockEvent);

      expect(mockEvent.preventDefault).toHaveBeenCalled();
    });

    it("only affects checkboxes within the initiate-form", () => {
      // Add checkboxes outside the form
      document.body.insertAdjacentHTML('beforeend', `
        <div>
          <input type="checkbox" id="outside-checkbox-1">
          <input type="checkbox" id="outside-checkbox-2">
        </div>
      `);

      const checkAllDevBtn = document.getElementById('check-all-dev');
      const outsideCheckboxes = document.querySelectorAll('#outside-checkbox-1, #outside-checkbox-2');
      
      // Ensure outside checkboxes start unchecked
      outsideCheckboxes.forEach(checkbox => {
        checkbox.checked = false;
      });

      // Click the check-all-dev button
      checkAllDevBtn.click();

      // Outside checkboxes should remain unchecked
      outsideCheckboxes.forEach(checkbox => {
        expect(checkbox.checked).toBe(false);
      });
    });
  });

  describe("checkSection", () => {
    it("checks all checkboxes in the specified section", () => {
      const usersSectionBtn = document.querySelector('[data-section="users"]');
      const usersCheckboxes = document.querySelectorAll('.users-checks input[type="checkbox"]');
      const ordersCheckboxes = document.querySelectorAll('.orders-checks input[type="checkbox"]');
      
      // Ensure all checkboxes start unchecked
      document.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
        checkbox.checked = false;
      });

      // Click the users section button
      usersSectionBtn.click();

      // Users checkboxes should be checked
      usersCheckboxes.forEach(checkbox => {
        expect(checkbox.checked).toBe(true);
      });

      // Orders checkboxes should remain unchecked
      ordersCheckboxes.forEach(checkbox => {
        expect(checkbox.checked).toBe(false);
      });
    });

    it("prevents default behavior on the event", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "checkbox");
      const mockEvent = {
        preventDefault: vi.fn(),
        currentTarget: document.querySelector('[data-section="users"]')
      };

      controller.checkSection(mockEvent);

      expect(mockEvent.preventDefault).toHaveBeenCalled();
    });

    it("works correctly for different sections", () => {
      const ordersSectionBtn = document.querySelector('[data-section="orders"]');
      const productsSectionBtn = document.querySelector('[data-section="products"]');
      
      const ordersCheckboxes = document.querySelectorAll('.orders-checks input[type="checkbox"]');
      const productsCheckboxes = document.querySelectorAll('.products-checks input[type="checkbox"]');
      
      // Ensure all checkboxes start unchecked
      document.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
        checkbox.checked = false;
      });

      // Click the orders section button
      ordersSectionBtn.click();
      
      // Only orders checkboxes should be checked
      ordersCheckboxes.forEach(checkbox => {
        expect(checkbox.checked).toBe(true);
      });
      productsCheckboxes.forEach(checkbox => {
        expect(checkbox.checked).toBe(false);
      });

      // Reset and test products section
      document.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
        checkbox.checked = false;
      });

      productsSectionBtn.click();
      
      // Only products checkboxes should be checked
      productsCheckboxes.forEach(checkbox => {
        expect(checkbox.checked).toBe(true);
      });
      ordersCheckboxes.forEach(checkbox => {
        expect(checkbox.checked).toBe(false);
      });
    });

    it("handles sections with no checkboxes gracefully", () => {
      // Add a section button with no corresponding checkboxes
      document.querySelector('.section-check-all').insertAdjacentHTML('afterend', `
        <button class="section-check-all" data-section="empty" type="button">Check All Empty</button>
      `);

      // Re-initialize to pick up the new button
      application.stop();
      application = Application.start();
      application.register("checkbox", CheckboxController);

      const emptySectionBtn = document.querySelector('[data-section="empty"]');

      // This should not throw an error
      expect(() => {
        emptySectionBtn.click();
      }).not.toThrow();
    });

    it("retrieves section name from data-section attribute correctly", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "checkbox");
      const usersSectionBtn = document.querySelector('[data-section="users"]');
      
      const mockEvent = {
        preventDefault: vi.fn(),
        currentTarget: usersSectionBtn
      };

      // Spy on getAttribute to verify it's called
      const getAttributeSpy = vi.spyOn(usersSectionBtn, 'getAttribute');
      
      controller.checkSection(mockEvent);

      expect(getAttributeSpy).toHaveBeenCalledWith('data-section');
    });
  });

  describe("event listener binding", () => {
    it("maintains correct context when event handlers are called", () => {
      const checkAllDevBtn = document.getElementById('check-all-dev');
      const allCheckboxes = document.querySelectorAll('#initiate-form input[type="checkbox"]');
      
      // Ensure all checkboxes start unchecked
      allCheckboxes.forEach(checkbox => {
        checkbox.checked = false;
      });
      
      // Click the button and verify the functionality works (indicating proper binding)
      checkAllDevBtn.click();
      
      // If the event handler is properly bound, all checkboxes should be checked
      allCheckboxes.forEach(checkbox => {
        expect(checkbox.checked).toBe(true);
      });
    });

    it("handles multiple section buttons correctly", () => {
      const sectionButtons = document.querySelectorAll('.section-check-all');
      
      // Test each section button to verify they work independently
      sectionButtons.forEach((button) => {
        // Reset all checkboxes
        document.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
          checkbox.checked = false;
        });
        
        const section = button.getAttribute('data-section');
        const sectionCheckboxes = document.querySelectorAll(`.${section}-checks input[type="checkbox"]`);
        
        // Click the section button
        button.click();
        
        // Verify only that section's checkboxes are checked
        sectionCheckboxes.forEach(checkbox => {
          expect(checkbox.checked).toBe(true);
        });
        
        // Verify other sections remain unchecked
        const otherSections = ['users', 'orders', 'products'].filter(s => s !== section);
        otherSections.forEach(otherSection => {
          const otherCheckboxes = document.querySelectorAll(`.${otherSection}-checks input[type="checkbox"]`);
          otherCheckboxes.forEach(checkbox => {
            expect(checkbox.checked).toBe(false);
          });
        });
      });
    });
  });
});