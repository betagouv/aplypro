import { Controller } from "@hotwired/stimulus"
import { mapColors } from "../utils/map_utils"

export default class extends Controller {
    static targets = ["generateButton", "regenerateButton", "downloadButton"]
    static values = { generateUrl: String, downloadUrl: String, currentVersion: Number }
    static maxAttempts = 30

    connect() {
        this.setProgressColor()
        this.generationTriggered = false
        this.checkStatus()
    }

    async generate(event) {
        const { isRegenerate, targetButton } = this.getGenerationContext(event)
        
        this.generationTriggered = true
        this.setButtonLoadingState(targetButton, true)

        try {
            const response = await this.sendGenerationRequest()
            if (response.ok) {
                this.pollForCompletion()
            } else {
                throw new Error('Generation failed')
            }
        } catch (error) {
            console.error('Generation error:', error)
            this.handleError('Erreur lors de la génération de l\'état liquidatif', targetButton, isRegenerate)
        }
    }

    async checkStatus() {
        try {
            const response = await fetch(this.downloadUrlValue, { method: 'HEAD' })
            response.ok ? this.showDownloadState() : this.showGenerateState()
        } catch {
            this.showGenerateState()
        }
    }

    getGenerationContext(event) {
        const clickedButton = event.target.closest('button')
        const isRegenerate = !!clickedButton.closest('[data-liquidation-target="regenerateButton"]')
        const targetLi = isRegenerate ? this.regenerateButtonTarget : this.generateButtonTarget
        const targetButton = targetLi.querySelector('button')
        
        return { isRegenerate, targetButton }
    }

    async sendGenerationRequest() {
        return fetch(this.generateUrlValue, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
            }
        })
    }

    async pollForCompletion() {
        const poll = async (attempts = 0) => {
            if (attempts >= this.constructor.maxAttempts) {
                this.handleError('Timeout: la génération prend trop de temps')
                return
            }

            try {
                const response = await fetch(this.downloadUrlValue, { method: 'HEAD' })
                if (response.ok) {
                    this.currentVersionValue += 1
                    this.showDownloadState()
                } else {
                    setTimeout(() => poll(attempts + 1), 2000)
                }
            } catch {
                setTimeout(() => poll(attempts + 1), 2000)
            }
        }
        poll()
    }

    setProgressColor() {
        document.documentElement.style.setProperty('--liquidation-progress-color', mapColors.lightGreen)
    }

    setButtonLoadingState(button, isLoading) {
        this.toggleLoading(button, isLoading)
        const text = isLoading ? 'Génération en cours...' : 'Générer états liquidatifs'
        this.updateButton(button, { disabled: isLoading, text })
    }

    toggleLoading(button, show) {
        button.classList.toggle('loading', show)
    }

    updateButton(button, { disabled, text }) {
        button.disabled = disabled
        const span = button.querySelector('span')
        if (span) {
            span.textContent = text
        } else {
            button.textContent = text
        }
    }

    updateDownloadButtonText() {
        if (!this.hasDownloadButtonTarget) return
        
        const version = this.currentVersionValue > 0 ? ` v${this.currentVersionValue}` : ''
        const link = this.downloadButtonTarget.querySelector('a')
        if (link) {
            link.textContent = `Télécharger les états liquidatifs${version}`
        }
    }

    showGenerateState() {
        this.setElementVisibility(this.generateButtonTarget, true, () => {
            const button = this.generateButtonTarget.querySelector('button')
            this.updateButton(button, { disabled: false, text: 'Générer états liquidatifs' })
        })
        this.setElementVisibility(this.regenerateButtonTarget, false)
        this.setElementVisibility(this.downloadButtonTarget, false)
    }

    showDownloadState() {
        this.setElementVisibility(this.generateButtonTarget, false, (button) => {
            this.toggleLoading(button, false)
        })
        
        this.setElementVisibility(this.regenerateButtonTarget, true, (button) => {
            this.toggleLoading(button, false)
            this.updateButton(button, { disabled: false, text: 'Regénérer les états liquidatifs' })
        })
        
        this.setElementVisibility(this.downloadButtonTarget, true)
        this.updateDownloadButtonText()

        if (this.generationTriggered) {
            this.showFlashNotification()
            this.generationTriggered = false
        }
    }

    setElementVisibility(target, isVisible, callback = null) {
        if (!target) return
        
        target.style.display = isVisible ? 'list-item' : 'none'
        
        if (isVisible && callback) {
            const button = target.querySelector('button')
            if (button) callback(button)
        }
    }

    showFlashNotification() {
        const flash = document.createElement('div')
        flash.className = 'liquidation-flash'
        flash.textContent = 'Nouveaux états liquidatifs disponibles'
        document.body.appendChild(flash)

        setTimeout(() => flash.remove(), 3000)
    }

    handleError(message, targetButton, isRegenerate = false) {
        this.toggleLoading(targetButton, false)
        const buttonText = isRegenerate ? 'Regénérer les états liquidatifs' : 'Générer états liquidatifs'
        this.updateButton(targetButton, { disabled: false, text: buttonText })
        alert(message)
    }
}
