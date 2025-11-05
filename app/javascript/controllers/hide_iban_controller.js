import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["text"]

    connect() {
        this.hidden = true
    }

    toggle() {
        const hide = this.textTarget.dataset.hide
        const full = this.textTarget.dataset.full
        this.textTarget.textContent = this.hidden ? full : hide
        this.hidden = !this.hidden
    }
}
