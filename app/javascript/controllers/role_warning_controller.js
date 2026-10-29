import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  confirmChange(event) {
    const select = event.target
    const currentRole = select.dataset.currentRole
    const newRole = select.value

    if (newRole === "contractor" && currentRole !== "contractor") {
      if (!confirm("Warning: Changing this user to a Contractor will remove all current school assignments. Do you wish to proceed?")) {
        select.value = currentRole // Revert back to original role
        event.preventDefault()
        event.stopPropagation()
        return
      }
    }
    
    // Proceed to submit the form automatically
    select.form.requestSubmit()
  }
}
