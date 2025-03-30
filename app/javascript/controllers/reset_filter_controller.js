import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["form"];

    reset() {
        if (!this.hasFormTarget) {
            console.error("Form target not found!");
            return;
        }

        const form = this.formTarget;

        form.querySelectorAll("input, select, textarea").forEach((field) => {
            if (field.type === "checkbox" || field.type === "radio") {
                field.checked = false;
            } else if ( field.type === "range" || field.type === "number") { 
                field.value = "1";
            } else {
                field.value = "";
            }
        });
        form.submit();
    }
}
