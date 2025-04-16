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
                    if (preview.tagName === 'IMG') {
                        preview.src = e.target.result
                    } else {
                        // If it's not an image, replace the initial with an image
                        const img = document.createElement('img')
                        img.src = e.target.result
                        img.className = 'rounded-full object-cover w-[100px] h-[100px] max-w-[100px] max-h-[100px]'
                        preview.parentNode.replaceChild(img, preview)
                        img.id = 'avatar-preview'
                    }
                }
            }
            reader.readAsDataURL(file)
        }
    }
} 