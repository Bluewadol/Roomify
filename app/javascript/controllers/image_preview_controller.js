import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["preview"]

    connect() {
        // If there's an existing image URL in data attributes, show it
        const imageUrl = this.element.dataset.imageUrl
        if (imageUrl) {
            const preview = this.previewTarget
            preview.classList.remove('hidden')
            preview.style.backgroundImage = `url(${imageUrl})`
            preview.style.backgroundSize = 'cover'
            preview.style.backgroundPosition = 'center'
        }
    }

    preview(event) {
        const file = event.target.files[0]
        if (file) {
            const reader = new FileReader()
            reader.onload = (e) => {
                const preview = this.previewTarget
                preview.classList.remove('hidden')
                preview.style.backgroundImage = `url(${e.target.result})`
                preview.style.backgroundSize = 'cover'
                preview.style.backgroundPosition = 'center'
            }
            reader.readAsDataURL(file)
        }
    }

    removeField() {
        this.previewTarget.classList.add("hidden")
    }
} 