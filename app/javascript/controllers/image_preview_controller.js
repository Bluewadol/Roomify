import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "preview", "uploadPlaceholder"]

    preview(event) {
        const file = this.inputTarget.files[0]
        if (file) {
            const reader = new FileReader()
            reader.onload = (e) => {
                this.previewTarget.style.backgroundImage = `url(${e.target.result})`
                this.previewTarget.classList.remove('hidden')
                this.uploadPlaceholderTarget.classList.add('opacity-0')
                this.uploadPlaceholderTarget.classList.add('group-hover:opacity-100')
            }
            reader.readAsDataURL(file)
        } else {
            this.previewTarget.classList.add('hidden')
            this.uploadPlaceholderTarget.classList.remove('opacity-0')
            this.uploadPlaceholderTarget.classList.remove('group-hover:opacity-100')
        }
    }
}
