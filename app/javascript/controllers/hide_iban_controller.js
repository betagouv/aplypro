import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["text"]

    connect() {
        this.isBlurred = true
    }

    toggle() {
        this.isBlurred = !this.isBlurred
        this.textTarget.classList.toggle("iban-blur", this.isBlurred)
    }
}
