import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["field", "container"]
    static values = {
        maxFiles: { type: Number, default: 4 }
    }

    connect() {
        this.updateCount()
    }

    addField() {
        if (this.getTotalImages() >= this.maxFilesValue) {
            alert(`You can only upload up to ${this.maxFilesValue} images.`)
            return
        }

        const wrapper = document.createElement("div")
        wrapper.className = "relative aspect-[16/9] rounded-lg overflow-hidden"
        wrapper.setAttribute("data-image-upload-target", "field")
        wrapper.innerHTML = `
            <div class="relative w-full h-full group hover:opacity-70 transition-opacity duration-300 hover:bg-neutral-100 hover:text-gray-900 text-gray-400" data-controller="image-preview">
                <input type="file" name="room[images][]" accept="image/jpeg,image/png,image/webp"
                    class="absolute inset-0 opacity-0 cursor-pointer w-full h-full z-10"
                    data-image-preview-target="input"
                    data-action="change->image-upload#validateFile change->image-preview#preview" />
                <div class="absolute inset-0 bg-cover bg-center hidden"
                    data-image-preview-target="preview"></div>
                <div class="absolute inset-0 flex flex-col gap-2 border border-dashed border-gray-400 rounded-lg items-center justify-center"
                    data-image-preview-target="uploadPlaceholder">
                    ${document.getElementById("upload-icon-template").innerHTML}
                    <span class="text-sm">Upload room Image</span>
                </div>
                <div class="absolute inset-0 flex items-center justify-center bg-red-100 text-red-600 hidden" data-image-upload-target="error">
                    <span class="text-sm font-medium">Invalid file type. Please upload JPEG, PNG, or WebP only.</span>
                </div>
                <button type="button"
                    class="absolute top-2 right-2 z-20 text-red-500 hover:text-red-600"
                    data-action="click->image-upload#removeField">
                    ${document.getElementById("trash-icon-template").innerHTML}
                </button>
            </div>
        `
        this.containerTarget.appendChild(wrapper)
        this.updateCount()
    }

    validateFile(event) {
        const file = event.target.files[0]
        const errorDiv = event.target.closest('[data-image-upload-target="field"]').querySelector('[data-image-upload-target="error"]')
        
        if (file) {
            const validTypes = ['image/jpeg', 'image/png', 'image/webp']
            if (!validTypes.includes(file.type)) {
                errorDiv.classList.remove('hidden')
                event.target.value = '' // Clear the invalid file
                return false
            }
            errorDiv.classList.add('hidden')
            return true
        }
    }

    removeField(event) {
        const field = event.currentTarget.closest('[data-image-upload-target="field"]')
        if (field) {
            field.remove()
            this.updateCount()
        }
    }

    removeImage(event) {
        const imageId = event.currentTarget.dataset.imageId
        if (imageId) {
            const input = document.createElement('input')
            input.type = 'hidden'
            input.name = 'room[remove_image_ids][]'
            input.value = imageId
            this.element.appendChild(input)

            event.currentTarget.closest('[data-image-upload-target="field"]').remove()
            this.updateCount()
        }
    }

    getTotalImages() {
        const existingImages = this.element.querySelectorAll('[data-image-id]').length
        const newFields = this.element.querySelectorAll('input[type="file"]').length
        return existingImages + newFields
    }

    updateCount() {
        const addBtn = this.element.querySelector('[data-action="click->image-upload#addField"]')
        if (addBtn) {
            addBtn.disabled = this.getTotalImages() >= this.maxFilesValue
        }
    }
}
