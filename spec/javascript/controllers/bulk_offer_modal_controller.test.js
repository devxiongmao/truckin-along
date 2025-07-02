import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Application } from "@hotwired/stimulus"
import BulkOfferModalController from "controllers/bulk_offer_modal_controller"

describe("BulkOfferModalController", () => {
  let application
  let controller
  let element

  beforeEach(() => {
    application = Application.start()
    application.register("bulk-offer-modal", BulkOfferModalController)
    
    // Create test element
    element = document.createElement("div")
    element.setAttribute("data-controller", "bulk-offer-modal")
    element.setAttribute("data-company-id", "123")
    
    // Add modal target
    const modal = document.createElement("div")
    modal.setAttribute("data-bulk-offer-modal-target", "modal")
    element.appendChild(modal)
    
    // Add form target
    const form = document.createElement("form")
    form.setAttribute("data-bulk-offer-modal-target", "form")
    element.appendChild(form)
    
    // Add shipment container target
    const shipmentContainer = document.createElement("div")
    shipmentContainer.setAttribute("data-bulk-offer-modal-target", "shipmentContainer")
    element.appendChild(shipmentContainer)
    
    document.body.appendChild(element)
    
    controller = application.getControllerForElementAndIdentifier(element, "bulk-offer-modal")
  })

  afterEach(() => {
    document.body.removeChild(element)
    application.stop()
  })

  describe("connect", () => {
    it("hides the modal on connect", () => {
      expect(controller.modalTarget.style.display).toBe("none")
    })
  })

  describe("showModal", () => {
    it("shows alert when no shipments are selected", () => {
      const alertSpy = vi.spyOn(window, "alert").mockImplementation(() => {})
      const event = { preventDefault: vi.fn() }
      
      controller.showModal(event)
      
      expect(alertSpy).toHaveBeenCalledWith("Please select at least one shipment to create offers for.")
      expect(event.preventDefault).toHaveBeenCalled()
      
      alertSpy.mockRestore()
    })

    it("shows modal when shipments are selected", () => {
      // Mock selected shipments
      const mockCheckbox = document.createElement("input")
      mockCheckbox.type = "checkbox"
      mockCheckbox.checked = true
      mockCheckbox.value = "1"
      
      const mockRow = document.createElement("tr")
      const nameCell = document.createElement("td")
      nameCell.textContent = "Test Shipment"
      const senderCell = document.createElement("td")
      senderCell.textContent = "123 Main St"
      const receiverCell = document.createElement("td")
      receiverCell.textContent = "456 Oak Ave"
      const weightCell = document.createElement("td")
      weightCell.textContent = "100 lbs"
      
      mockRow.appendChild(document.createElement("td")) // checkbox cell
      mockRow.appendChild(document.createElement("td")) // status cell
      mockRow.appendChild(nameCell)
      mockRow.appendChild(senderCell)
      mockRow.appendChild(receiverCell)
      mockRow.appendChild(weightCell)
      
      mockCheckbox.closest = vi.fn().mockReturnValue(mockRow)
      
      // Mock querySelector to return our mock checkbox
      const querySelectorSpy = vi.spyOn(document, "querySelectorAll")
        .mockReturnValue([mockCheckbox])
      
      const event = { preventDefault: vi.fn() }
      
      controller.showModal(event)
      
      expect(controller.modalTarget.style.display).toBe("flex")
      expect(event.preventDefault).toHaveBeenCalled()
      
      querySelectorSpy.mockRestore()
    })
  })

  describe("hideModal", () => {
    it("hides the modal", () => {
      controller.modalTarget.style.display = "flex"
      
      controller.hideModal()
      
      expect(controller.modalTarget.style.display).toBe("none")
    })
  })

  describe("createShipmentEntry", () => {
    it("creates a shipment entry with correct structure", () => {
      const entry = controller.createShipmentEntry("1", "Test Shipment", "123 Main St", "456 Oak Ave", "100 lbs", 0)
      
      expect(entry.className).toBe("shipment-entry")
      expect(entry.innerHTML).toContain("Test Shipment")
      expect(entry.innerHTML).toContain("123 Main St")
      expect(entry.innerHTML).toContain("456 Oak Ave")
      expect(entry.innerHTML).toContain("100 lbs")
      expect(entry.innerHTML).toContain('name="offers[0][price]"')
      expect(entry.innerHTML).toContain('name="offers[0][shipment_id]"')
      expect(entry.innerHTML).toContain('value="1"')
    })
  })

  describe("toggleReceptionAddress", () => {
    it("shows reception address when pickup is unchecked", () => {
      // Create mock elements
      const mockGroup = document.createElement("div")
      mockGroup.id = "reception_address_0"
      mockGroup.style.display = "none"
      
      const mockInput = document.createElement("input")
      mockInput.id = "reception_address_input_0"
      
      document.getElementById = vi.fn()
        .mockReturnValueOnce(mockGroup)
        .mockReturnValueOnce(mockInput)
      
      const event = { target: { dataset: { index: "0" }, checked: false } }
      
      controller.toggleReceptionAddress(event)
      
      expect(mockGroup.style.display).toBe("block")
      expect(mockInput.hasAttribute("required")).toBe(true)
    })

    it("hides reception address when pickup is checked", () => {
      // Create mock elements
      const mockGroup = document.createElement("div")
      mockGroup.id = "reception_address_0"
      mockGroup.style.display = "block"
      
      const mockInput = document.createElement("input")
      mockInput.id = "reception_address_input_0"
      mockInput.setAttribute("required", "required")
      mockInput.value = "test address"
      
      document.getElementById = vi.fn()
        .mockReturnValueOnce(mockGroup)
        .mockReturnValueOnce(mockInput)
      
      const event = { target: { dataset: { index: "0" }, checked: true } }
      
      controller.toggleReceptionAddress(event)
      
      expect(mockGroup.style.display).toBe("none")
      expect(mockInput.hasAttribute("required")).toBe(false)
      expect(mockInput.value).toBe("")
    })
  })

  describe("toggleDropoffLocation", () => {
    it("shows dropoff location when deliver to door is unchecked", () => {
      // Create mock elements
      const mockGroup = document.createElement("div")
      mockGroup.id = "dropoff_location_0"
      mockGroup.style.display = "none"
      
      const mockInput = document.createElement("input")
      mockInput.id = "dropoff_location_input_0"
      
      document.getElementById = vi.fn()
        .mockReturnValueOnce(mockGroup)
        .mockReturnValueOnce(mockInput)
      
      const event = { target: { dataset: { index: "0" }, checked: false } }
      
      controller.toggleDropoffLocation(event)
      
      expect(mockGroup.style.display).toBe("block")
      expect(mockInput.hasAttribute("required")).toBe(true)
    })

    it("hides dropoff location when deliver to door is checked", () => {
      // Create mock elements
      const mockGroup = document.createElement("div")
      mockGroup.id = "dropoff_location_0"
      mockGroup.style.display = "block"
      
      const mockInput = document.createElement("input")
      mockInput.id = "dropoff_location_input_0"
      mockInput.setAttribute("required", "required")
      mockInput.value = "test location"
      
      document.getElementById = vi.fn()
        .mockReturnValueOnce(mockGroup)
        .mockReturnValueOnce(mockInput)
      
      const event = { target: { dataset: { index: "0" }, checked: true } }
      
      controller.toggleDropoffLocation(event)
      
      expect(mockGroup.style.display).toBe("none")
      expect(mockInput.hasAttribute("required")).toBe(false)
      expect(mockInput.value).toBe("")
    })
  })

  describe("getCurrentCompanyId", () => {
    it("returns company ID from data attribute", () => {
      expect(controller.getCurrentCompanyId()).toBe("123")
    })

    it("returns empty string when no company ID is set", () => {
      element.removeAttribute("data-company-id")
      expect(controller.getCurrentCompanyId()).toBe("")
    })
  })

  describe("submitForm", () => {
    it("submits form when shipments are selected", () => {
      const submitSpy = vi.spyOn(controller.formTarget, "submit")
      
      // Mock selected shipments
      const mockCheckbox = document.createElement("input")
      mockCheckbox.type = "checkbox"
      mockCheckbox.checked = true
      
      const querySelectorSpy = vi.spyOn(document, "querySelectorAll")
        .mockReturnValue([mockCheckbox])
      
      controller.submitForm()
      
      expect(submitSpy).toHaveBeenCalled()
      
      submitSpy.mockRestore()
      querySelectorSpy.mockRestore()
    })

    it("shows alert when no shipments are selected", () => {
      const alertSpy = vi.spyOn(window, "alert").mockImplementation(() => {})
      const querySelectorSpy = vi.spyOn(document, "querySelectorAll")
        .mockReturnValue([])
      
      controller.submitForm()
      
      expect(alertSpy).toHaveBeenCalledWith("Please select at least one shipment to create offers for.")
      
      alertSpy.mockRestore()
      querySelectorSpy.mockRestore()
    })
  })
}) 