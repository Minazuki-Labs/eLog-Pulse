import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "ticket", "text", "icon" ]

  connect() {
    this.isExpanded = false
    this.updateButtonText()
  }

  toggle(event) {
    event.preventDefault()
    this.isExpanded = !this.isExpanded

    this.ticketTargets.forEach((row, index) => {
      if (index >= 5) {
        row.classList.toggle("hidden", !this.isExpanded)
      }
    })

    if (this.isExpanded) {
      if (this.hasTextTarget) this.textTarget.textContent = "Show Less"
      if (this.hasIconTarget) this.iconTarget.classList.add("rotate-180")
    } else {
      this.updateButtonText()
      if (this.hasIconTarget) this.iconTarget.classList.remove("rotate-180")
      
      document.getElementById("ticket-history-heading")?.scrollIntoView({ behavior: 'smooth' })
    }
  }

  updateButtonText() {
    if (this.hasTextTarget) {
      const hiddenCount = Math.max(0, this.ticketTargets.length - 5)
      this.textTarget.textContent = `Show More (${hiddenCount} hidden)`
    }
  }
}