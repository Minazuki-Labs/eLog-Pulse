import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "subItem"]
  static values = { subItems: Object }

  connect() {
  }

  filterSubItems() {
    const itemId = this.itemTarget.value
    const subItemSelect = this.subItemTarget

    subItemSelect.innerHTML = '<option value="">Select Sub Item</option>'

    if (!itemId) return

    const matchingSubItems = this.subItemsValue[itemId] || []

    matchingSubItems.forEach(sub => {
      const option = document.createElement("option")
      option.value = sub.id
      option.textContent = sub.name
      subItemSelect.appendChild(option)
    })
  }
}
