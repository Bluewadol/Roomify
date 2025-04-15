import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["field", "container"];
    static values = {
        maxFiles: { type: Number, default: 4 }
    };

    connect() {
        this.updateCount();
    }

    addField() {
        if (this.getTotalImages() >= this.maxFilesValue) {
            alert(`You can only upload up to ${this.maxFilesValue} images.`);
            return;
        }

        const newField = document.createElement('div');
        newField.className = 'flex flex-col gap-2 hover:cursor-pointer';
        newField.setAttribute('data-image-upload-target', 'field');
        newField.innerHTML = `
            <div class="flex items-center justify-between h-full rounded-lg overflow-hidden">
                <div class="flex items-center justify-center h-full">
                    <input type="file" 
                        name="room[images][]" 
                        accept="image/*" 
                        class="form-file border-none outline-none cursor-pointer w-full h-full"
                        data-controller="image-preview"
                        data-action="change->image-preview#preview">
                </div>
                <button type="button" class="text-red-500 hover:text-red-600" 
                    data-action="click->image-upload#removeField">
                    ${document.getElementById('trash-icon-template').innerHTML}
                </button>
            </div>
        `;

        this.containerTarget.appendChild(newField);
        this.updateCount();
    }

    removeField(event) {
        const field = event.currentTarget.closest('[data-image-upload-target="field"]');
        if (field) {
            field.remove();
            this.updateCount();
        }
    }

    removeImage(event) {
        const imageId = event.currentTarget.dataset.imageId;
        if (imageId) {
            // Add a hidden input to mark the image for removal
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'room[remove_image_ids][]';
            input.value = imageId;
            this.element.appendChild(input);
            
            // Remove the image element
            event.currentTarget.closest('.relative').remove();
            this.updateCount();
        }
    }

    getTotalImages() {
        const existingImages = this.element.querySelectorAll('[data-image-id]').length;
        const newImageFields = this.element.querySelectorAll('input[type="file"]').length;
        return existingImages + newImageFields;
    }

    updateCount() {
        const addButton = this.element.querySelector('[data-action="click->image-upload#addField"]');
        if (addButton) {
            addButton.disabled = this.getTotalImages() >= this.maxFilesValue;
        }
    }
}
