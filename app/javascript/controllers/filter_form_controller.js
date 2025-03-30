import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["input", "form"];

    connect() {
        console.log("filter_form controller loaded");
    }

    submit(event) {
        this.formTarget.submit();
    }

    clearInputAndSubmit(event) {
        const fieldId = event.currentTarget.dataset.fieldId;
        const inputField = document.getElementById(fieldId);
        if (inputField) {
        inputField.value = "";
        this.formTarget.submit();
        }
    }
}