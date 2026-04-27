import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]

  toggle() {
    this.contentTarget.classList.toggle("grid-rows-[1fr]")
    this.contentTarget.classList.toggle("grid-rows-[0fr]")

    this.iconTarget.classList.toggle("rotate-180")
  }
}