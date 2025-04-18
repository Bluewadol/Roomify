import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "startDateField", "endDateField"];

  connect() {
    const bangkokDate = new Date(new Date().toLocaleString("en-US", { timeZone: "Asia/Bangkok" }));
    const formattedDate = bangkokDate.toISOString().split('T')[0]; 

    const urlParams = new URLSearchParams(window.location.search);
    if (!urlParams.has('start_date') && !urlParams.has('end_date')) {
      if (this.hasStartDateFieldTarget) {
        this.startDateFieldTarget.value = formattedDate;
      }
      if (this.hasEndDateFieldTarget) {
        this.endDateFieldTarget.value = formattedDate;
      }
      
      this.formTarget.submit();
    } else {
      this.updateUrlParams();
    }
  }

  updateUrlParams() {
    const newUrl = new URL(window.location);

    if (this.hasStartDateFieldTarget) {
      const startDateValue = this.startDateFieldTarget.value;
      if (startDateValue) {
        newUrl.searchParams.set("start_date", startDateValue);
      } else {
        newUrl.searchParams.delete("start_date");
      }
    }

    if (this.hasEndDateFieldTarget) {
      const endDateValue = this.endDateFieldTarget.value;
      if (endDateValue) {
        newUrl.searchParams.set("end_date", endDateValue);
      } else {
        newUrl.searchParams.delete("end_date");
      }
    }

    window.history.pushState({}, "", newUrl);
  }

  handleInputChange(event) {
    this.updateUrlParams();

    this.formTarget.submit();
  }

  reset() {
    if (!this.hasFormTarget) {
      console.error("Form target not found!");
      return;
    }

    const form = this.formTarget;

    form.querySelectorAll("input, select, textarea").forEach((field) => {
      if (field.type === "checkbox" || field.type === "radio") {
        field.checked = false;
      } else if (field.type === "range" || field.type === "number") {
        field.value = "1";
      } else if (field.type === "date") {
        const currentDate = new Date();
        const formattedDate = currentDate.toISOString().split("T")[0];
        field.value = formattedDate;
      } else if (field.type === "time") {
        field.value = "";
      } else {
        field.value = "";
      }
    });

    form.submit();
  }
}
