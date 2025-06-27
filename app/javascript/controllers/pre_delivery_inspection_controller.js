import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.setupEventListeners()
  }

  disconnect() {
    this.removeEventListeners()
  }

  setupEventListeners() {
    // Development mode: Check all checkboxes
    this.checkAllDevBtn = document.getElementById('check-all-dev')
    if (this.checkAllDevBtn) {
      this.checkAllDevBtn.addEventListener('click', this.checkAllDev.bind(this))
    }

    // Production mode: Check section-specific checkboxes
    this.sectionButtons = document.querySelectorAll('.section-check-all')
    this.sectionButtons.forEach(button => {
      button.addEventListener('click', this.checkSection.bind(this))
    })
  }

  removeEventListeners() {
    if (this.checkAllDevBtn) {
      this.checkAllDevBtn.removeEventListener('click', this.checkAllDev.bind(this))
    }

    this.sectionButtons.forEach(button => {
      button.removeEventListener('click', this.checkSection.bind(this))
    })
  }

  checkAllDev(event) {
    event.preventDefault()
    const allCheckboxes = document.querySelectorAll('#initiate-form input[type="checkbox"]')
    allCheckboxes.forEach(checkbox => {
      checkbox.checked = true
    })
  }

  checkSection(event) {
    event.preventDefault()
    const section = event.currentTarget.getAttribute('data-section')
    const sectionCheckboxes = document.querySelectorAll(`.${section}-checks input[type="checkbox"]`)

    sectionCheckboxes.forEach(checkbox => {
      checkbox.checked = true
    })
  }
} 