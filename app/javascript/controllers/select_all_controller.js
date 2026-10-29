import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["master", "item"]

  toggle() {
    const isChecked = this.masterTarget.checked
    this.itemTargets.forEach(checkbox => {
      checkbox.checked = isChecked
    })
  }
}
