import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["hiddenInput"]

    connect() {
        this.buildInputs()
    }

    buildInputs() {
        const hidden = this.hiddenInputTarget
        const value = hidden.value.replace(/\s+/g, "")

        const container = document.createElement("div")
        container.classList.add("fr-input-group", "fr-mt-1w")
        container.style.gap = "5px"
        container.style.display = "flex"

        const lengthPerPart = 4
        this.inputFields = []

        for (let i = 0; i < 7; i++) {
            const input = document.createElement("input")
            input.type = "text"
            input.inputMode = "numeric"
            input.maxLength = lengthPerPart
            input.classList.add("iban-part", "fr-input", "fr-col-md-1")
            input.dataset.index = i

            // Inject prefilled value
            input.value = value.slice(i * lengthPerPart, (i + 1) * lengthPerPart)

            input.addEventListener("input", this.handleInput.bind(this))
            input.addEventListener("keydown", this.handleBackspace.bind(this))
            input.addEventListener("paste", this.handlePaste.bind(this))

            this.inputFields.push(input)
            container.appendChild(input)
        }

        hidden.type = "hidden"
        hidden.after(container)
    }

    handlePaste(e) {
        e.preventDefault()
        const pasteData = (e.clipboardData || window.clipboardData).getData("text").replace(/\s+/g, "")

        // Remplir chaque champ avec 4 caractères de la chaîne
        this.inputFields.forEach((input, i) => {
            const start = i * 4
            input.value = pasteData.slice(start, start + 4)
        })

        // Met à jour le champ caché
        this.updateHiddenInput()

        // Focus sur le dernier champ non vide
        const nextEmpty = this.inputFields.find(i => i.value.length < i.maxLength)
        if (nextEmpty) nextEmpty.focus()
    }

    handleInput(e) {
        const input = e.target
        const index = parseInt(input.dataset.index)

        if (input.value.length === input.maxLength && index < this.inputFields.length - 1) {
            this.inputFields[index + 1].focus()
        }

        this.updateHiddenInput()
    }

    handleBackspace(e) {
        const input = e.target
        const index = parseInt(input.dataset.index)

        if (e.key === "Backspace" && input.value === "" && index > 0) {
            this.inputFields[index - 1].focus()
        }
    }

    updateHiddenInput() {
        this.hiddenInputTarget.value = this.inputFields.map(i => i.value).join("")
    }
}
