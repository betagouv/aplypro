import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["part", "hidden"]
    static values = { initial: String }

    connect() {
        this.partTargets.forEach((input, index) => {
            input.addEventListener("paste", (e) => this.handlePaste(e))
            input.addEventListener("input", () => this.handleInput(index))
        })

        if (this.hasInitialValue && this.initialValue.length > 0) {
            this.prefillParts(this.initialValue)
        }

        this.updateHidden()
    }

    prefillParts(iban) {
        const clean = iban.replace(/\s+/g, "").toUpperCase()
        this.partTargets.forEach((input, i) => {
            const slice = clean.slice(i * 4, (i + 1) * 4)
            input.value = slice || ""
        })
    }

    handlePaste(e) {
        e.preventDefault()
        const pasted = (e.clipboardData || window.clipboardData).getData("text")
        const clean = pasted.replace(/\s+/g, "").toUpperCase()

        this.prefillParts(clean)
        this.updateHidden()
    }

    handleInput(index) {
        const input = this.partTargets[index]
        if (input.value.length === input.maxLength && index < this.partTargets.length - 1) {
            this.partTargets[index + 1].focus()
        }
        this.updateHidden()
    }

    updateHidden() {
        this.hiddenTarget.value = this.partTargets.map(i => i.value).join("").toUpperCase()
    }
}