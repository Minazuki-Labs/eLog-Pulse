import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]

  toggle() {
    this.contentTarget.classList.toggle("grid-rows-[1fr]")
    this.contentTarget.classList.toggle("grid-rows-[0fr]")
    this.contentTarget.classList.toggle("opacity-100")
    this.contentTarget.classList.toggle("opacity-0")
    this.contentTarget.classList.toggle("visible")
    this.contentTarget.classList.toggle("invisible")

    this.iconTarget.classList.toggle("rotate-180")
  }
}