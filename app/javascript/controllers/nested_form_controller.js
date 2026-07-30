import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template", "destroy"]

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.containerTarget.insertAdjacentHTML('beforeend', content)
  }

  remove(event) {
    event.preventDefault()
    const wrapper = event.target.closest('.nested-fields')
    
    if (wrapper.dataset.newRecord === "true") {
      wrapper.remove()
    } else {
      wrapper.querySelector('[data-nested-form-target="destroy"]').value = "1"
      wrapper.style.display = 'none'
    }
  }
}