import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["preview"]

    preview(event) {
        const file = event.target.files[0]
        if (file) {
            const reader = new FileReader()
            reader.onload = (e) => {
                const preview = document.getElementById('avatar-preview')
                if (preview) {
                    preview.src = e.target.result
                }
            }
            reader.readAsDataURL(file)
        }
    }
} 