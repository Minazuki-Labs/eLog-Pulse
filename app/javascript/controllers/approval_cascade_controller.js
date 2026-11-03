import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["managerWrapper", "approver2Wrapper", "approver2Select", "managerSelect"]

  connect() {
    this.updateVisibility()
  }

  approver2Changed() {
    this.updateVisibility()
  }

  managerChanged() {
    this.updateVisibility()
  }

  updateVisibility() {
    const hasApprover2 = (this.hasApprover2SelectTarget && this.approver2SelectTarget.value !== "") || 
                         document.querySelector("[data-approval-2-locked]") !== null

    const hasManager = this.hasManagerSelectTarget && this.managerSelectTarget.value !== ""

    if (this.hasApprover2WrapperTarget) {
      if (hasManager) {
        // If order manager is selected, hide approver 2 and show only company name + manager
        this.approver2WrapperTarget.classList.add("hidden")
      } else {
        // Otherwise show approver 2
        this.approver2WrapperTarget.classList.remove("hidden")
      }
    }

    if (this.hasManagerWrapperTarget) {
      if (hasApprover2) {
        // If approver 2 is present/selected, show manager wrapper
        this.managerWrapperTarget.classList.remove("hidden")
      } else {
        // Otherwise hide manager wrapper
        this.managerWrapperTarget.classList.add("hidden")
        if (this.hasManagerSelectTarget) this.managerSelectTarget.value = ""
      }
    }
  }
}
