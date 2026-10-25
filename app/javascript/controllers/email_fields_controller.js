import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]
  static values = { max: { type: Number, default: 3 } }

  connect() {
    this.updateButtons()
  }

  add(event) {
    event.preventDefault()
    const count = this.containerTarget.querySelectorAll('.email-group').length
    
    if (count < this.maxValue) {
      const content = this.templateTarget.innerHTML.replace(/TEMPLATE_RECORD/g, new Date().getTime())
      this.containerTarget.insertAdjacentHTML('beforeend', content)
      this.updateButtons()
    }
  }

  remove(event) {
    event.preventDefault()
    const group = event.target.closest('.email-group')
    const count = this.containerTarget.querySelectorAll('.email-group').length

    // Keep at least 1 email input visible since min is 1
    if (count > 1) {
      group.remove()
      this.updateButtons()
    }
  }

  updateButtons() {
    const groups = this.containerTarget.querySelectorAll('.email-group')
    const addBtn = this.element.querySelector('[data-action*="email-fields#add"]')
    
    // Hide "Add Email" button if max reached, show otherwise
    if (addBtn) {
      addBtn.style.display = groups.length >= this.maxValue ? 'none' : 'block'
    }

    // Toggle remove button visibility (hide if only 1 remains)
    groups.forEach(group => {
      const removeBtn = group.querySelector('.remove-btn')
      if (removeBtn) {
        removeBtn.style.display = groups.length > 1 ? 'inline-block' : 'none'
      }
    })
  }
}
