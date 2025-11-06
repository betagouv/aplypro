import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggleText", "wrapper", "frame"]
  static values = { src: String }

  connect() {
    this.loaded = false
  }

  toggle(event) {
    event.preventDefault()

    if (this.wrapperTarget.classList.contains("hidden")) {
      this.wrapperTarget.classList.remove("hidden")
      this.toggleTextTarget.textContent = "Masquer le détail des établissements"

      if (!this.loaded) {
        this.frameTarget.src = this.srcValue
        this.loaded = true
      }
    } else {
      this.wrapperTarget.classList.add("hidden")
      this.toggleTextTarget.textContent = "Afficher le détail des établissements"
    }
  }
}
