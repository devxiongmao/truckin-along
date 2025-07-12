import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="rating-modal"
export default class extends Controller {
  static targets = [
    "modal", 
    "form", 
    "stars", 
    "comment", 
    "deliveryShipmentId",
    "companyId",
    "submitBtn",
    "closeBtn"
  ]
  
  connect() {
    this.modalTarget.style.display = "none"
    this.selectedStars = 0
    this.hoveredStars = 0
  }
  
  showModal(event) {
    event.preventDefault()
    const deliveryShipmentId = event.currentTarget.dataset.deliveryShipmentId
    const companyId = event.currentTarget.dataset.companyId
    this.deliveryShipmentIdTarget.value = deliveryShipmentId
    this.companyIdTarget.value = companyId
    this.starsTargets.forEach(star => star.checked = false)
    this.commentTarget.value = ""
    this.selectedStars = 0
    this.hoveredStars = 0
    this.updateStarDisplay()
    this.modalTarget.style.display = "flex"
  }
  
  hideModal() {
    this.modalTarget.style.display = "none"
  }

  hoverStar(event) {
    const hovered = parseInt(event.currentTarget.querySelector('input').dataset.stars)
    this.hoveredStars = hovered
    this.updateStarDisplay()
  }

  resetHover() {
    this.hoveredStars = 0
    this.updateStarDisplay()
  }

  selectStar(event) {
    const selected = parseInt(event.currentTarget.querySelector('input').dataset.stars)
    this.selectedStars = selected
    this.starsTargets.forEach((star) => {
      const starValue = parseInt(star.dataset.stars)
      star.checked = (starValue <= selected)
    })
    this.updateStarDisplay()
  }

  updateStarDisplay() {
    const count = this.hoveredStars || this.selectedStars
    this.starsTargets.forEach((star) => {
      const starSpan = star.parentElement.querySelector('.star-display')
      const starValue = parseInt(star.dataset.stars)
      if (starValue <= count) {
        starSpan.classList.add('full-star')
      } else {
        starSpan.classList.remove('full-star')
      }
    })
  }

  submitForm(event) {
    event.preventDefault()
    const selectedStars = this.selectedStars
    if (selectedStars === 0) {
      alert('Please select a rating (1-5 stars)')
      return
    }
    
    // Create a hidden input for the star rating and submit the form normally
    const starRatingInput = document.createElement('input')
    starRatingInput.type = 'hidden'
    starRatingInput.name = 'rating[stars]'
    starRatingInput.value = selectedStars
    
    // Add the hidden input to the form
    this.formTarget.appendChild(starRatingInput)
    
    this.formTarget.submit()
  }
}