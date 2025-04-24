import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["originalInput"]
    static values = {
        maxLength: { type: Number, default: 34 },
        minLength: { type: Number, default: 15 },
        defaultLength: { type: Number, default: 7 }
    }

    initialize() {
      this.handleInput = this.handleInput.bind(this)
      this.handleKeydown = this.handleKeydown.bind(this)
      this.handlePaste = this.handlePaste.bind(this)
      this.inputFields = []
    }

    connect() {
        if (!this.element.querySelector('.iban-container')) {
            this.buildInputs()
        }
    }

    disconnect() {
        this.inputFields?.forEach(input => {
            input.removeEventListener("input", this.handleInput.bind(this))
            input.removeEventListener("keydown", this.handleKeydown.bind(this))
            input.removeEventListener("paste", this.handlePaste.bind(this))
        })
    }

    buildInputs(valueOverride = null) {
        const hidden = this.originalInputTarget
        const value = (valueOverride || hidden.value).replace(/\s+/g, "")
        const numParts = Math.ceil(value.length / 4) || this.defaultLengthValue

        const existingContainers = this.element.parentElement.querySelectorAll('.iban-container')
        existingContainers.forEach(container => container.remove())

        const container = document.createElement("div")
        container.classList.add("fr-input-group", "fr-mt-1w", "iban-container")
        container.setAttribute("role", "group")
        container.setAttribute("aria-label", "IBAN input field group")

        const lengthPerPart = 4

        for (let i = 0; i < numParts; i++) {
            const input = document.createElement("input")
            input.type = "text"
            input.inputMode = "numeric"
            input.maxLength = lengthPerPart
            input.classList.add("iban-part", "fr-input")
            input.dataset.index = i
            input.setAttribute("aria-label", `IBAN part ${i + 1} of ${numParts}`)

            input.value = value.slice(i * lengthPerPart, (i + 1) * lengthPerPart)

            input.addEventListener("input", this.handleInput.bind(this))
            input.addEventListener("keydown", this.handleKeydown.bind(this))
            input.addEventListener("paste", this.handlePaste.bind(this))

            this.inputFields.push(input)
            container.appendChild(input)
        }

        const clearButton = document.createElement("button")
        clearButton.type = "button"
        clearButton.classList.add("fr-btn", "fr-btn--tertiary", "fr-btn--sm", "iban-clear-button")
        clearButton.setAttribute("aria-label", "Clear IBAN")
        clearButton.innerHTML = '<i class="fr-icon-close-line" aria-hidden="true"></i>'
        clearButton.setAttribute("data-action", "click->iban#clear")
        clearButton.style.display = value ? "block" : "none"

        container.appendChild(clearButton)

        hidden.type = "hidden"
        hidden.after(container)
    }

    handlePaste(e) {
        try {
            e.preventDefault()
            const pasteData = (e.clipboardData || window.clipboardData).getData("text")
                .replace(/\s+/g, "")
                .replace(/[^A-Z0-9]/gi, '')
                .toUpperCase()

            if (pasteData.length > this.maxLengthValue) {
                console.error(`Pasted IBAN is too long. Maximum length is ${this.maxLengthValue} characters.`)
                return
            }

            if (pasteData.length < this.minLengthValue) {
                console.error(`Pasted IBAN is too short. Minimum length is ${this.minLengthValue} characters.`)
                return
            }

            const neededFields = Math.ceil(pasteData.length / 4)

            if (neededFields !== this.inputFields.length) {
                this.buildInputs(pasteData)
            } else {
                this.inputFields.forEach((input, i) => {
                    const start = i * 4
                    input.value = pasteData.slice(start, start + 4)
                })
            }

            this.updateoriginalInput()
            this.toggleClearButton("block")

            const nextEmpty = this.inputFields.find(i => i.value.length < i.maxLength)
            if (nextEmpty) nextEmpty.focus()
        } catch (error) {
            console.error("IBAN Paste failed:", error)
        }
    }

    handleInput(e) {
        try {
            const input = e.target
            input.value = input.value.replace(/[^A-Z0-9]/gi, '').toUpperCase()

            const index = parseInt(input.dataset.index)

            if (input.value.length === input.maxLength && index < this.inputFields.length - 1) {
                this.inputFields[index + 1].focus()
            }

            this.updateoriginalInput()
            this.toggleClearButton(this.hasAnyInput() ? "block" : "none")
        } catch (error) {
            console.error("IBAN Input handling failed:", error)
        }
    }

    handleKeydown(e) {
        try {
            const input = e.target
            const index = parseInt(input.dataset.index)
            const cursorPosition = input.selectionStart

            switch (e.key) {
                case "Backspace":
                    if (input.value === "" && index > 0) {
                        this.inputFields[index - 1].focus()
                    }
                    break
                case "ArrowLeft":
                    if (cursorPosition === 0 && index > 0) {
                        e.preventDefault()
                        const prevInput = this.inputFields[index - 1]
                        prevInput.focus()
                        prevInput.setSelectionRange(prevInput.value.length, prevInput.value.length)
                    }
                    break
                case "ArrowRight":
                    if (cursorPosition === input.value.length && index < this.inputFields.length - 1) {
                        e.preventDefault()
                        const nextInput = this.inputFields[index + 1]
                        nextInput.focus()
                        nextInput.setSelectionRange(0, 0)
                    }
                    break
            }
        } catch (error) {
            console.error("IBAN Key handling failed:", error)
        }
    }

    clear(e) {
        try {
            e.preventDefault()
            this.inputFields.forEach(input => {
                input.value = ""
            })
            this.updateoriginalInput()
            this.toggleClearButton("none")
            this.inputFields[0].focus()
        } catch (error) {
            console.error("IBAN Clear failed:", error)
        }
    }

    updateoriginalInput() {
        try {
            const combinedValue = this.inputFields.map(i => i.value).join("")
            this.originalInputTarget.value = combinedValue

            const event = new Event('change', { bubbles: true })
            this.originalInputTarget.dispatchEvent(event)
        } catch (error) {
            console.error("IBAN Hidden input update failed:", error)
        }
    }

    hasAnyInput() {
        return this.inputFields.some(input => input.value.length > 0)
    }

    toggleClearButton(displayMode) {
        const clearButton = this.element.querySelector('.iban-clear-button')
        if (clearButton) {
            clearButton.style.display = displayMode
        }
    }
}
