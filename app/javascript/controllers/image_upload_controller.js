import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["field"];
    static values = {
        maxFiles: { type: Number, default: 4 }
    };

    connect() {
        this.updateCount();
    }

    addField() {
        if (this.fieldTargets.length >= this.maxFilesValue) {
            alert(`You can only upload up to ${this.maxFilesValue} images.`);
            return;
        }

        const newField = document.createElement('div');
        newField.className = 'relative pb-4';
        newField.setAttribute('data-image-upload-target', 'field');
        newField.innerHTML = `
            <div class="aspect-w-16 aspect-h-9 rounded-lg overflow-hidden">
                <div class="flex items-center justify-center h-full">
                    <input type="file" 
                        name="room[images][]" 
                        accept="image/*" 
                        class="form-file border-none outline-none cursor-pointer"
                        data-controller="image-preview"
                        data-action="change->image-preview#preview">
                </div>
                <div class="image-preview hidden absolute inset-0 w-full h-full" data-image-preview-target="preview"></div>
            </div>
            <button type="button" class="absolute top-2 right-2 text-red-500 hover:text-red-600" 
                data-action="click->image-upload#removeField">
            </button>
        `;

        // Clone and append the trash icon from the template
        const trashIconTemplate = document.getElementById('trash-icon-template');
        const trashIcon = trashIconTemplate.content.cloneNode(true);
        newField.querySelector('button').appendChild(trashIcon);

        this.element.querySelector('#image-upload-container').appendChild(newField);
        this.updateCount();
    }

    removeField(event) {
        event.target.closest('[data-image-upload-target="field"]').remove();
        this.updateCount();
    }

    updateCount() {
        const addButton = this.element.querySelector("[data-action='click->image-upload#addField']");
        if (this.fieldTargets.length >= this.maxFilesValue) {
            addButton.disabled = true;
        } else {
            addButton.disabled = false;
        }
    }
}
