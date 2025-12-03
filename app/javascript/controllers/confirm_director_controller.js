import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["checkbox", "submit"]

    connect() {
        this.toggleSubmitButton()
    }

    toggleSubmitButton() {
        this.submitTarget.disabled = !this.checkboxTarget.checked
    }
}
