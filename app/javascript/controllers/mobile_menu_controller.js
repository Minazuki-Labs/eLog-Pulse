import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drawer", "backdrop"]

  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
  }

  toggle() {
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    if (!this.hasDrawerTarget) return
    this.drawerTarget.classList.remove("-translate-x-full")
    this.drawerTarget.classList.add("translate-x-0")

    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove("hidden")
    }
  }

  close() {
    if (!this.hasDrawerTarget) return
    this.drawerTarget.classList.add("-translate-x-full")
    this.drawerTarget.classList.remove("translate-x-0")

    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.add("hidden")
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape" && this.isOpen) {
      this.close()
    }
  }

  get isOpen() {
    return this.hasDrawerTarget && !this.drawerTarget.classList.contains("-translate-x-full")
  }
}
