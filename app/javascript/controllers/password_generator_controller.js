import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "confirmation", "display", "plainView"]

  generate(event) {
    event.preventDefault()
    
    const chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    let password = ""
    for (let i = 0; i < 12; i++) {
      password += chars.charAt(Math.floor(Math.random() * chars.length))
    }

    if (this.hasInputTarget) {
      this.inputTarget.value = password
    }
    
    if (this.hasConfirmationTarget) {
      this.confirmationTarget.value = password
    }
    
    if (this.hasDisplayTarget) {
      this.displayTarget.classList.remove("hidden")
    }
    
    if (this.hasPlainViewTarget) {
      this.plainViewTarget.textContent = password
    }
  }
}
