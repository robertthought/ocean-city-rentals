import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    const button = event.currentTarget
    const content = button.nextElementSibling
    const icon = button.querySelector("svg")

    if (content) {
      content.classList.toggle("hidden")
    }

    if (icon) {
      icon.classList.toggle("rotate-180")
    }
  }
}
