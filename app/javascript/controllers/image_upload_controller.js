import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["field"];

    connect() {
        this.maxFiles = 4;
        this.updateCount();
    }

    addField() {
        event.preventDefault(); 
        if (this.fieldTargets.length >= this.maxFiles) {
        alert("You can only upload up to 4 images.");
        return;
        }

        const container = document.querySelector("#image-upload-container");
        const newField = document.createElement("div");
        newField.classList.add("relative", "mb-2");
        newField.innerHTML = `
        <input type="file" name="room[images][]" accept="image/png,image/jpeg,image/webp" class="form-control" data-action="change->image-upload#updateCount">
        <button type="button" class="text-red-500 text-sm ml-2" onclick="this.parentElement.remove();">✖ Remove</button>
        `;
        container.appendChild(newField);
        this.updateCount();
    }

    updateCount() {
        if (this.fieldTargets.length >= this.maxFiles) {
        this.element.querySelector("[data-action='click->image-upload#addField']").disabled = true;
        } else {
        this.element.querySelector("[data-action='click->image-upload#addField']").disabled = false;
        }
    }
}
