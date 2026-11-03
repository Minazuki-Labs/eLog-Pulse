import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["contractorCheckbox"]

  confirmChange(event) {
    const checkbox = event.target
    const isBecomingContractor = checkbox.checked
    const wasContractor = checkbox.dataset.wasContractor === "true"

    if (isBecomingContractor && !wasContractor) {
      if (!confirm("Warning: Changing this user to a Contractor will remove all current school assignments. Do you wish to proceed?")) {
        checkbox.checked = false // Revert checkbox state
        event.preventDefault()
        event.stopPropagation()
        return
      }
    }
  }
}
