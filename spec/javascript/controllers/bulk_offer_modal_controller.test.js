import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";
import { Application } from "@hotwired/stimulus";
import BulkOfferModalController from "controllers/bulk_offer_modal_controller";

describe("BulkOfferModalController", () => {
  let application;
  let container;
  let mockAlert;
  let mockSubmit;

  function createBasicModalHTML() {
    return `
      <div data-controller="bulk-offer-modal">
        <div data-bulk-offer-modal-target="modal" class="modal">
          <form data-bulk-offer-modal-target="form" action="/bulk_offers" method="post">
            <div data-bulk-offer-modal-target="shipmentContainer"></div>
            <button type="submit" data-bulk-offer-modal-target="submitBtn" data-action="click->bulk-offer-modal#submitForm">Submit</button>
            <button type="button" data-bulk-offer-modal-target="closeBtn" data-action="click->bulk-offer-modal#hideModal">Close</button>
          </form>
        </div>
      </div>
    `;
  }

  function createShipmentTableHTML() {
    return `
      <table>
        <tbody>
          <tr>
            <td><input type="checkbox" name="shipment_ids[]" value="1"></td>
            <td>1</td>
            <td>Package 1</td>
            <td>123 Main St, New York, NY</td>
            <td>456 Oak Ave, Los Angeles, CA</td>
            <td>5.2 lbs</td>
          </tr>
          <tr>
            <td><input type="checkbox" name="shipment_ids[]" value="2"></td>
            <td>2</td>
            <td>Package 2</td>
            <td>789 Pine St, Chicago, IL</td>
            <td>321 Elm St, Houston, TX</td>
            <td>3.8 lbs</td>
          </tr>
        </tbody>
      </table>
    `;
  }

  beforeEach(() => {
    vi.clearAllMocks();
    
    // Mock window.alert
    mockAlert = vi.fn();
    global.alert = mockAlert;
    
    // Mock form submit
    mockSubmit = vi.fn();
    HTMLFormElement.prototype.submit = mockSubmit;

    const modalHTML = createBasicModalHTML();
    document.body.innerHTML = modalHTML + createShipmentTableHTML();

    application = Application.start();
    application.register("bulk-offer-modal", BulkOfferModalController);

    container = document.querySelector('[data-controller="bulk-offer-modal"]');
  });

  afterEach(() => {
    document.body.innerHTML = "";
    application.stop();
    delete global.alert;
    delete HTMLFormElement.prototype.submit;
  });

  describe("connect", () => {
    it("hides the modal on connect", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "bulk-offer-modal");
      const modal = container.querySelector('[data-bulk-offer-modal-target="modal"]');
      
      controller.connect();
      
      expect(modal.style.display).toBe("none");
    });
  });

  describe("showModal", () => {
    let controller;
    let event;

    beforeEach(() => {
      controller = application.getControllerForElementAndIdentifier(container, "bulk-offer-modal");
      event = { preventDefault: vi.fn() };
    });

    it("prevents default event behavior", () => {
      // Select a shipment
      const checkbox = document.querySelector('input[name="shipment_ids[]"]');
      checkbox.checked = true;

      controller.showModal(event);

      expect(event.preventDefault).toHaveBeenCalled();
    });

    it("shows alert when no shipments are selected", () => {
      controller.showModal(event);

      expect(mockAlert).toHaveBeenCalledWith('Please select at least one shipment to create offers for.');
    });

    it("does not show modal when no shipments are selected", () => {
      const modal = container.querySelector('[data-bulk-offer-modal-target="modal"]');

      controller.showModal(event);

      expect(modal.style.display).toBe("none");
    });

    it("shows modal when shipments are selected", () => {
      const checkbox = document.querySelector('input[name="shipment_ids[]"]');
      checkbox.checked = true;
      const modal = container.querySelector('[data-bulk-offer-modal-target="modal"]');

      controller.showModal(event);

      expect(modal.style.display).toBe("flex");
    });

    it("clears previous shipment entries before creating new ones", () => {
      const shipmentContainer = container.querySelector('[data-bulk-offer-modal-target="shipmentContainer"]');
      shipmentContainer.innerHTML = '<div>Previous content</div>';
      
      const checkbox = document.querySelector('input[name="shipment_ids[]"]');
      checkbox.checked = true;

      controller.showModal(event);

      expect(shipmentContainer.innerHTML).not.toContain('Previous content');
    });

    it("creates shipment entries for selected shipments", () => {
      const checkboxes = document.querySelectorAll('input[name="shipment_ids[]"]');
      checkboxes[0].checked = true;
      checkboxes[1].checked = true;

      controller.showModal(event);

      const shipmentContainer = container.querySelector('[data-bulk-offer-modal-target="shipmentContainer"]');
      const entries = shipmentContainer.querySelectorAll('.shipment-entry');
      
      expect(entries).toHaveLength(2);
    });

    it("creates entries with correct shipment data", () => {
      const checkbox = document.querySelector('input[name="shipment_ids[]"]');
      checkbox.checked = true;

      controller.showModal(event);

      const shipmentContainer = container.querySelector('[data-bulk-offer-modal-target="shipmentContainer"]');
      
      expect(shipmentContainer.innerHTML).toContain('Package 1');
      expect(shipmentContainer.innerHTML).toContain('123 Main St, New York, NY');
      expect(shipmentContainer.innerHTML).toContain('456 Oak Ave, Los Angeles, CA');
      expect(shipmentContainer.innerHTML).toContain('5.2 lbs');
    });
  });

  describe("hideModal", () => {
    it("hides the modal", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "bulk-offer-modal");
      const modal = container.querySelector('[data-bulk-offer-modal-target="modal"]');
      
      modal.style.display = "flex";
      controller.hideModal();

      expect(modal.style.display).toBe("none");
    });
  });

  describe("extractShipmentData", () => {
    it("extracts correct data from shipment row", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "bulk-offer-modal");
      const row = document.querySelector('tr');

      const data = controller.extractShipmentData(row);

      expect(data).toEqual({
        name: 'Package 1',
        senderAddress: '123 Main St, New York, NY',
        receiverAddress: '456 Oak Ave, Los Angeles, CA',
        weight: '5.2 lbs'
      });
    });

    it("handles missing data gracefully", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "bulk-offer-modal");
      const emptyRow = document.createElement('tr');

      const data = controller.extractShipmentData(emptyRow);

      expect(data).toEqual({
        name: '',
        senderAddress: '',
        receiverAddress: '',
        weight: ''
      });
    });
  });

  describe("createShipmentEntry", () => {
    it("creates entry with correct shipment ID", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "bulk-offer-modal");
      const shipmentData = {
        name: 'Test Package',
        senderAddress: 'Test Sender',
        receiverAddress: 'Test Receiver',
        weight: '10 lbs'
      };

      const entry = controller.createShipmentEntry('123', shipmentData, 0);

      const hiddenInput = entry.querySelector('input[name="bulk_offer[offers_attributes][0][shipment_id]"]');
      expect(hiddenInput.value).toBe('123');
    });

    it("creates form fields with correct names and IDs", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "bulk-offer-modal");
      const shipmentData = {
        name: 'Test Package',
        senderAddress: 'Test Sender',
        receiverAddress: 'Test Receiver',
        weight: '10 lbs'
      };

      const entry = controller.createShipmentEntry('123', shipmentData, 2);

      expect(entry.querySelector('#offer_price_2')).not.toBeNull();
      expect(entry.querySelector('input[name="bulk_offer[offers_attributes][2][price]"]')).not.toBeNull();
      expect(entry.querySelector('#pickup_from_sender_2')).not.toBeNull();
      expect(entry.querySelector('#deliver_to_door_2')).not.toBeNull();
    });

    it("sets default checkbox states correctly", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "bulk-offer-modal");
      const shipmentData = {
        name: 'Test Package',
        senderAddress: 'Test Sender',
        receiverAddress: 'Test Receiver',
        weight: '10 lbs'
      };

      const entry = controller.createShipmentEntry('123', shipmentData, 0);

      const pickupCheckbox = entry.querySelector('#pickup_from_sender_0');
      const deliverCheckbox = entry.querySelector('#deliver_to_door_0');
      
      expect(pickupCheckbox.checked).toBe(true);
      expect(deliverCheckbox.checked).toBe(true);
    });

    it("hides conditional fields by default", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "bulk-offer-modal");
      const shipmentData = {
        name: 'Test Package',
        senderAddress: 'Test Sender',
        receiverAddress: 'Test Receiver',
        weight: '10 lbs'
      };

      const entry = controller.createShipmentEntry('123', shipmentData, 0);

      const receptionGroup = entry.querySelector('#reception_address_group_0');
      const dropoffGroup = entry.querySelector('#dropoff_location_group_0');
      
      expect(receptionGroup.style.display).toBe('none');
      expect(dropoffGroup.style.display).toBe('none');
    });

    it("includes hidden inputs for checkboxes", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "bulk-offer-modal");
      const shipmentData = {
        name: 'Test Package',
        senderAddress: 'Test Sender',
        receiverAddress: 'Test Receiver',
        weight: '10 lbs'
      };

      const entry = controller.createShipmentEntry('123', shipmentData, 0);

      const hiddenInputs = entry.querySelectorAll('input[type="hidden"]');
      const hiddenNames = Array.from(hiddenInputs).map(input => input.name);
      
      expect(hiddenNames).toContain('bulk_offer[offers_attributes][0][pickup_from_sender]');
      expect(hiddenNames).toContain('bulk_offer[offers_attributes][0][deliver_to_door]');
      expect(hiddenNames).toContain('bulk_offer[offers_attributes][0][pickup_at_dropoff]');
    });
  });

  describe("toggleReceptionAddress", () => {
    let controller;
    let entry;

    beforeEach(() => {
      controller = application.getControllerForElementAndIdentifier(container, "bulk-offer-modal");
      const shipmentData = {
        name: 'Test Package',
        senderAddress: 'Test Sender',
        receiverAddress: 'Test Receiver',
        weight: '10 lbs'
      };
      entry = controller.createShipmentEntry('123', shipmentData, 0);
      document.body.appendChild(entry);
    });

    it("hides reception address when pickup from sender is checked", () => {
      const event = { target: { checked: true, dataset: { index: '0' } } };

      controller.toggleReceptionAddress(event);

      const receptionGroup = entry.querySelector('#reception_address_group_0');
      const receptionInput = entry.querySelector('#reception_address_0');
      
      expect(receptionGroup.style.display).toBe('none');
      expect(receptionInput.hasAttribute('required')).toBe(false);
      expect(receptionInput.value).toBe('');
    });

    it("shows reception address when pickup from sender is unchecked", () => {
      const event = { target: { checked: false, dataset: { index: '0' } } };

      controller.toggleReceptionAddress(event);

      const receptionGroup = entry.querySelector('#reception_address_group_0');
      const receptionInput = entry.querySelector('#reception_address_0');
      
      expect(receptionGroup.style.display).toBe('block');
      expect(receptionInput.hasAttribute('required')).toBe(true);
    });
  });

  describe("toggleDropoffLocation", () => {
    let controller;
    let entry;

    beforeEach(() => {
      controller = application.getControllerForElementAndIdentifier(container, "bulk-offer-modal");
      const shipmentData = {
        name: 'Test Package',
        senderAddress: 'Test Sender',
        receiverAddress: 'Test Receiver',
        weight: '10 lbs'
      };
      entry = controller.createShipmentEntry('123', shipmentData, 0);
      document.body.appendChild(entry);
    });

    it("hides dropoff location when deliver to door is checked", () => {
      const event = { target: { checked: true, dataset: { index: '0' } } };

      controller.toggleDropoffLocation(event);

      const dropoffGroup = entry.querySelector('#dropoff_location_group_0');
      const dropoffInput = entry.querySelector('#dropoff_location_0');
      
      expect(dropoffGroup.style.display).toBe('none');
      expect(dropoffInput.hasAttribute('required')).toBe(false);
      expect(dropoffInput.value).toBe('');
    });

    it("shows dropoff location when deliver to door is unchecked", () => {
      const event = { target: { checked: false, dataset: { index: '0' } } };

      controller.toggleDropoffLocation(event);

      const dropoffGroup = entry.querySelector('#dropoff_location_group_0');
      const dropoffInput = entry.querySelector('#dropoff_location_0');
      
      expect(dropoffGroup.style.display).toBe('block');
      expect(dropoffInput.hasAttribute('required')).toBe(true);
    });
  });

  describe("submitForm", () => {
    let controller;

    beforeEach(() => {
      controller = application.getControllerForElementAndIdentifier(container, "bulk-offer-modal");
      // Create a shipment entry for testing
      const checkbox = document.querySelector('input[name="shipment_ids[]"]');
      checkbox.checked = true;
      const event = { preventDefault: vi.fn() };
      controller.showModal(event);
    });

    it("prevents default event behavior when event is provided", () => {
      const event = { preventDefault: vi.fn() };

      // Set valid price
      const priceInput = container.querySelector('input[type="number"]');
      priceInput.value = '50.00';

      controller.submitForm(event);

      expect(event.preventDefault).toHaveBeenCalled();
    });

    it("submits form when all validations pass", () => {
      const priceInput = container.querySelector('input[type="number"]');
      priceInput.value = '50.00';

      controller.submitForm();

      expect(mockSubmit).toHaveBeenCalled();
    });

    it("shows alert and does not submit when prices are invalid", () => {
      const priceInput = container.querySelector('input[type="number"]');
      priceInput.value = '0';

      controller.submitForm();

      expect(mockAlert).toHaveBeenCalledWith('Please enter valid prices for all offers.');
      expect(mockSubmit).not.toHaveBeenCalled();
    });

    it("shows alert and does not submit when prices are empty", () => {
      const priceInput = container.querySelector('input[type="number"]');
      priceInput.value = '';

      controller.submitForm();

      expect(mockAlert).toHaveBeenCalledWith('Please enter valid prices for all offers.');
      expect(mockSubmit).not.toHaveBeenCalled();
    });

    it("adds error class to invalid price inputs", () => {
      const priceInput = container.querySelector('input[type="number"]');
      priceInput.value = '-10';

      controller.submitForm();

      expect(priceInput.classList.contains('error')).toBe(true);
    });

    it("removes error class from valid price inputs", () => {
      const priceInput = container.querySelector('input[type="number"]');
      priceInput.classList.add('error');
      priceInput.value = '50.00';

      controller.submitForm();

      expect(priceInput.classList.contains('error')).toBe(false);
    });

    it("validates multiple price inputs", async () => {
      // Add a second shipment
      const checkboxes = document.querySelectorAll('input[name="shipment_ids[]"]');
      checkboxes[1].checked = true;
      
      // Trigger showModal again to include the second shipment
      const event = { preventDefault: vi.fn() };
      controller.showModal(event);

      const priceInputs = container.querySelectorAll('input[type="number"]');
      priceInputs[0].value = '50.00'; // Valid
      priceInputs[1].value = '0';     // Invalid

      controller.submitForm();

      expect(mockAlert).toHaveBeenCalledWith('Please enter valid prices for all offers.');
      expect(mockSubmit).not.toHaveBeenCalled();
      expect(priceInputs[0].classList.contains('error')).toBe(false);
      expect(priceInputs[1].classList.contains('error')).toBe(true);
    });
  });

  describe("integration tests", () => {
    it("handles complete workflow from show to submit", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "bulk-offer-modal");
      
      // Select shipment
      const checkbox = document.querySelector('input[name="shipment_ids[]"]');
      checkbox.checked = true;
      
      // Show modal
      const showEvent = { preventDefault: vi.fn() };
      controller.showModal(showEvent);
      
      // Verify modal is shown with correct content
      const modal = container.querySelector('[data-bulk-offer-modal-target="modal"]');
      expect(modal.style.display).toBe("flex");
      
      const shipmentContainer = container.querySelector('[data-bulk-offer-modal-target="shipmentContainer"]');
      expect(shipmentContainer.innerHTML).toContain('Package 1');
      
      // Fill in price
      const priceInput = container.querySelector('input[type="number"]');
      priceInput.value = '75.50';
      
      // Submit form
      controller.submitForm();
      
      expect(mockSubmit).toHaveBeenCalled();
    });

    it("handles conditional field toggling correctly", () => {
      const controller = application.getControllerForElementAndIdentifier(container, "bulk-offer-modal");
      
      // Create entry
      const checkbox = document.querySelector('input[name="shipment_ids[]"]');
      checkbox.checked = true;
      const event = { preventDefault: vi.fn() };
      controller.showModal(event);
      
      // Test pickup from sender toggle
      const pickupCheckbox = container.querySelector('#pickup_from_sender_0');
      pickupCheckbox.checked = false;
      const pickupEvent = { target: { checked: false, dataset: { index: '0' } } };
      controller.toggleReceptionAddress(pickupEvent);
      
      const receptionGroup = container.querySelector('#reception_address_group_0');
      expect(receptionGroup.style.display).toBe('block');
      
      // Test deliver to door toggle
      const deliverCheckbox = container.querySelector('#deliver_to_door_0');
      deliverCheckbox.checked = false;
      const deliverEvent = { target: { checked: false, dataset: { index: '0' } } };
      controller.toggleDropoffLocation(deliverEvent);
      
      const dropoffGroup = container.querySelector('#dropoff_location_group_0');
      expect(dropoffGroup.style.display).toBe('block');
    });
  });
});