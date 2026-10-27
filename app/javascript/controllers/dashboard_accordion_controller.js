import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "state", "school" ]

  toggleState(event) {
    const details = event.currentTarget.closest("details")
    if (details.open) return

    this.stateTargets.forEach(target => {
      if (target !== details) {
        target.removeAttribute("open")
      }
    })
  }

  toggleSchool(event) {
    const details = event.currentTarget.closest("details")
    if (details.open) return

    const stateContainer = details.closest("[data-dashboard-accordion-target='state']")
    const schoolTargets = stateContainer ? stateContainer.querySelectorAll("[data-dashboard-accordion-target='school']") : this.schoolTargets

    schoolTargets.forEach(target => {
      if (target !== details) {
        target.removeAttribute("open")
      }
    })
  }
}
