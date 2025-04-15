import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["preview"]

    preview(event) {
        const file = event.target.files[0]
        if (file) {
            const reader = new FileReader()
            const previewTarget = this.previewTarget
            
            reader.onload = function(e) {
                // Create image element
                const img = document.createElement('img')
                img.src = e.target.result
                img.className = 'w-full h-full object-cover'
                img.alt = 'Preview'
                
                // Clear previous preview and show new one
                previewTarget.innerHTML = ''
                previewTarget.appendChild(img)
                previewTarget.classList.remove('hidden')
            }
            
            reader.readAsDataURL(file)
        }
    }

    removeField() {
        this.previewTarget.classList.add("hidden")
    }
} 