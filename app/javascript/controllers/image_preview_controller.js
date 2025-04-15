import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "preview"]

    preview(event) {
        const file = this.inputTarget.files[0]
        if (file) {
            const reader = new FileReader()
            reader.onload = (e) => {
            this.previewTarget.classList.remove("hidden")
            this.previewTarget.style.backgroundImage = `url(${e.target.result})`
            this.previewTarget.style.backgroundSize = "cover"
            this.previewTarget.style.backgroundPosition = "center"
            }
            reader.readAsDataURL(file)
        }
    }
}
