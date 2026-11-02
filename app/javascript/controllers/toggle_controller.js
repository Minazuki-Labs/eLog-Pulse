import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]
  static values = { id: String }

  connect() {
    if (!this.hasIdValue) return
    const isCollapsed = localStorage.getItem(`sidebar_${this.idValue}`) === "true"

    if (isCollapsed) {
      this.contentTarget.classList.remove("grid-rows-[1fr]", "opacity-100", "visible")
      this.contentTarget.classList.add("grid-rows-[0fr]", "opacity-0", "invisible")
      
      this.iconTarget.classList.remove("rotate-180")
    }
  }

  toggle() {
    this.contentTarget.classList.toggle("grid-rows-[1fr]")
    this.contentTarget.classList.toggle("grid-rows-[0fr]")
    this.contentTarget.classList.toggle("opacity-100")
    this.contentTarget.classList.toggle("opacity-0")
    this.contentTarget.classList.toggle("visible")
    this.contentTarget.classList.toggle("invisible")

    this.iconTarget.classList.toggle("rotate-180")

    if (this.hasIdValue) {
      const isNowCollapsed = this.contentTarget.classList.contains("grid-rows-[0fr]")
      localStorage.setItem(`sidebar_${this.idValue}`, isNowCollapsed)
    }
  }
}