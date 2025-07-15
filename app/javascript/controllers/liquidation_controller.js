import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        this.element.addEventListener('turbo:submit-end', this.handleSubmitEnd.bind(this))

        const statusElement = document.getElementById('liquidation-status')
        if (statusElement) {
            this.observer = new MutationObserver(() => {
                const button = statusElement.querySelector('input[type="submit"]')
                if (button && button.value.includes('Regénérer')) {
                    this.showCompletionMessage()
                }
            })
            this.observer.observe(statusElement, { childList: true, subtree: true })
        }
    }

    disconnect() {
        this.element.removeEventListener('turbo:submit-end', this.handleSubmitEnd.bind(this))
        if (this.observer) {
            this.observer.disconnect()
        }
    }

    handleSubmitEnd(event) {
        if (event.detail.success) {
            this.showStartMessage()
        } else {
            alert('Erreur lors de la génération de l\'état liquidatif')
        }
    }

    showStartMessage() {
        this.showFlash('Génération démarrée')
    }

    showCompletionMessage() {
        this.showFlash('Nouveaux états liquidatifs disponibles')
    }

    showFlash(message) {
        const flash = document.createElement('div')
        flash.className = 'liquidation-flash'
        flash.textContent = message
        document.body.appendChild(flash)
        setTimeout(() => flash.remove(), 3000)
    }
}
