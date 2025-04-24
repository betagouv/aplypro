import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["originalInput", "container", "clearButton", "part"]
    static values = {
        maxLength: { type: Number, default: 34 },
        minLength: { type: Number, default: 15 },
        defaultLength: { type: Number, default: 7 }
    }
    static classes = ["input", "container", "clearButton", "part"]

    initialize() {
        this.handleInput = this.handleInput.bind(this)
        this.handleKeydown = this.handleKeydown.bind(this)
        this.handlePaste = this.handlePaste.bind(this)
    }

    connect() {
        if (!this.hasContainerTarget) {
            this.buildInputs()
        }
    }

    disconnect() {
        this.removeEventListeners()
    }

    buildInputs(valueOverride = null) {
        const value = this.sanitizeIbanValue(valueOverride || this.originalInputTarget.value)
        const numParts = Math.ceil(value.length / 4) || this.defaultLengthValue

        this.containerTargets.forEach(container => container.remove())

        const container = document.createElement("div")
        container.classList.add("fr-input-group", "fr-mt-1w", this.containerClass)
        container.setAttribute("role", "group")
        container.setAttribute("aria-label", "IBAN input field group")
        container.setAttribute("data-iban-target", "container")

        const lengthPerPart = 4

        for (let i = 0; i < numParts; i++) {
            const input = document.createElement("input")
            input.type = "text"
            input.inputMode = "numeric"
            input.maxLength = lengthPerPart
            input.classList.add(this.partClass, this.inputClass)
            input.dataset.index = i
            input.setAttribute("data-iban-target", "part")
            input.setAttribute("aria-label", `IBAN part ${i + 1} of ${numParts}`)
            input.value = value.slice(i * lengthPerPart, (i + 1) * lengthPerPart)

            input.addEventListener("input", this.handleInput)
            input.addEventListener("keydown", this.handleKeydown)
            input.addEventListener("paste", this.handlePaste)

            container.appendChild(input)
        }

        const clearButton = document.createElement("button")
        clearButton.type = "button"
        clearButton.classList.add("fr-btn", "fr-btn--tertiary", "fr-btn--sm", this.clearButtonClass)
        clearButton.setAttribute("data-iban-target", "clearButton")
        clearButton.setAttribute("aria-label", "Clear IBAN")
        clearButton.innerHTML = '<i class="fr-icon-close-line" aria-hidden="true"></i>'
        clearButton.setAttribute("data-action", "click->iban#clear")
        clearButton.style.display = value ? "block" : "none"

        container.appendChild(clearButton)
        this.originalInputTarget.type = "hidden"
        this.originalInputTarget.after(container)
    }

    handlePaste(e) {
        try {
            e.preventDefault()
            const pasteData = this.sanitizeIbanValue(
                (e.clipboardData || window.clipboardData).getData("text")
            )

            if (!this.isValidIbanLength(pasteData)) return

            const neededFields = Math.ceil(pasteData.length / 4)

            if (neededFields !== this.partTargets.length) {
                this.buildInputs(pasteData)
            } else {
                this.distributeValueToParts(pasteData)
            }

            this.updateoriginalInput()
            this.toggleClearButton("block")
            this.focusNextEmptyField()
        } catch (error) {
            console.error("IBAN Paste failed:", error)
        }
    }

    handleInput(e) {
        try {
            const input = e.target
            input.value = this.sanitizeIbanValue(input.value)

            this.handleAutoFocus(input)
            this.updateoriginalInput()
            this.updateClearButtonVisibility()
        } catch (error) {
            console.error("IBAN Input handling failed:", error)
        }
    }

    handleKeydown(e) {
        try {
            const input = e.target
            const index = parseInt(input.dataset.index)
            const cursorPosition = input.selectionStart

            const keyHandlers = {
                Backspace: () => this.handleBackspace(input, index),
                ArrowLeft: () => this.handleArrowLeft(input, index, cursorPosition),
                ArrowRight: () => this.handleArrowRight(input, index, cursorPosition)
            }

            const handler = keyHandlers[e.key]
            if (handler) {
                handler()
            }
        } catch (error) {
            console.error("IBAN Key handling failed:", error)
        }
    }

    clear(e) {
        try {
            e.preventDefault()
            this.clearAllInputs()
            this.updateoriginalInput()
            this.toggleClearButton("none")
            this.partTargets[0].focus()
        } catch (error) {
            console.error("IBAN Clear failed:", error)
        }
    }

    sanitizeIbanValue(value) {
        return value.replace(/\s+/g, "")
            .replace(/[^A-Z0-9]/gi, '')
            .toUpperCase()
    }

    isValidIbanLength(value) {
        if (value.length > this.maxLengthValue) {
            console.error(`IBAN is too long. Maximum length is ${this.maxLengthValue} characters.`)
            return false
        }
        if (value.length < this.minLengthValue) {
            console.error(`IBAN is too short. Minimum length is ${this.minLengthValue} characters.`)
            return false
        }
        return true
    }

    distributeValueToParts(value) {
        this.partTargets.forEach((input, i) => {
            const start = i * 4
            input.value = value.slice(start, start + 4)
        })
    }

    handleAutoFocus(input) {
        const index = parseInt(input.dataset.index)
        if (input.value.length === input.maxLength && index < this.partTargets.length - 1) {
            this.partTargets[index + 1].focus()
        }
    }

    handleBackspace(input, index) {
        if (input.value === "" && index > 0) {
            this.partTargets[index - 1].focus()
        }
    }

    handleArrowLeft(input, index, cursorPosition) {
        if (cursorPosition === 0 && index > 0) {
            event.preventDefault()
            const prevInput = this.partTargets[index - 1]
            prevInput.focus()
            prevInput.setSelectionRange(prevInput.value.length, prevInput.value.length)
        }
    }

    handleArrowRight(input, index, cursorPosition) {
        if (cursorPosition === input.value.length && index < this.partTargets.length - 1) {
            event.preventDefault()
            const nextInput = this.partTargets[index + 1]
            nextInput.focus()
            nextInput.setSelectionRange(0, 0)
        }
    }

    focusNextEmptyField() {
        const nextEmpty = this.partTargets.find(i => i.value.length < i.maxLength)
        if (nextEmpty) nextEmpty.focus()
    }

    updateoriginalInput() {
        try {
            const combinedValue = this.partTargets.map(i => i.value).join("")
            this.originalInputTarget.value = combinedValue
            this.originalInputTarget.dispatchEvent(new Event('change', { bubbles: true }))
        } catch (error) {
            console.error("IBAN Hidden input update failed:", error)
        }
    }

    updateClearButtonVisibility() {
        this.toggleClearButton(this.hasAnyInput() ? "block" : "none")
    }

    hasAnyInput() {
        return this.partTargets.some(input => input.value.length > 0)
    }

    toggleClearButton(displayMode) {
        if (this.hasClearButtonTarget) {
            this.clearButtonTarget.style.display = displayMode
        }
    }

    clearAllInputs() {
        this.partTargets.forEach(input => {
            input.value = ""
        })
    }

    removeEventListeners() {
        this.partTargets?.forEach(input => {
            input.removeEventListener("input", this.handleInput)
            input.removeEventListener("keydown", this.handleKeydown)
            input.removeEventListener("paste", this.handlePaste)
        })
    }
}
