import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]
  static values = { max: { type: Number, default: 3 } }

  connect() {
    this.updateButtons()
  }

  add(event) {
    event.preventDefault()
    const count = this.containerTarget.querySelectorAll('.email-group:not([style*="display: none"])').length
    
    if (count < this.maxValue) {
      const content = this.templateTarget.innerHTML.replace(/TEMPLATE_RECORD/g, new Date().getTime())
      this.containerTarget.insertAdjacentHTML('beforeend', content)
      this.updateButtons()
    }
  }

  remove(event) {
    event.preventDefault()
    const group = event.target.closest('.email-group')
    const idInput = group.querySelector('input[name*="[id]"]')
    const destroyInput = group.querySelector('.destroy-flag')
    const count = this.containerTarget.querySelectorAll('.email-group:not([style*="display: none"])').length

    // Keep at least 1 input visible since min is 1
    if (count > 1) {
      if (idInput && destroyInput) {
        destroyInput.value = "1"
        group.style.display = 'none'
      } else {
        // If it's a newly added dynamic record, safely remove it from the DOM
        group.remove()
      }
      this.updateButtons()
    }
  }

  updateButtons() {
    const groups = this.containerTarget.querySelectorAll('.email-group:not([style*="display: none"])')
    const addBtn = this.element.querySelector('[data-action*="email-fields#add"]')
    
    // Hide "Add" button if max reached, show otherwise
    if (addBtn) {
      addBtn.style.display = groups.length >= this.maxValue ? 'none' : 'block'
    }

    // Toggle remove button visibility
    const allGroups = this.containerTarget.querySelectorAll('.email-group')
    allGroups.forEach(group => {
      const removeBtn = group.querySelector('.remove-btn')
      if (removeBtn) {
        removeBtn.style.display = groups.length > 1 ? 'inline-block' : 'none'
      }
    })
  }
}
