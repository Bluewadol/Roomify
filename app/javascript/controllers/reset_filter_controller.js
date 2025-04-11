import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "startDateField", "endDateField"];

  connect() {
    // เรียก updateUrlParams เมื่อฟอร์มถูกโหลด
    console.log("Stimulus controller connected");
    this.updateUrlParams();
  }

  updateUrlParams() {
    const newUrl = new URL(window.location);
    console.log("Input changed");

    // ตรวจสอบว่า start_date ถูกเลือกหรือไม่
    if (this.hasStartDateFieldTarget) {
      const startDateValue = this.startDateFieldTarget.value;
      if (startDateValue) {
        newUrl.searchParams.set("start_date", startDateValue);
      } else {
        newUrl.searchParams.delete("start_date");
      }
    }

    // ตรวจสอบว่า end_date ถูกเลือกหรือไม่
    if (this.hasEndDateFieldTarget) {
      const endDateValue = this.endDateFieldTarget.value;
      if (endDateValue) {
        newUrl.searchParams.set("end_date", endDateValue);
      } else {
        newUrl.searchParams.delete("end_date");
      }
    }

    // อัปเดต URL
    window.history.pushState({}, "", newUrl);
  }

  handleInputChange(event) {
    // อัปเดต URL ทุกครั้งที่ฟอร์มเปลี่ยนแปลง
    this.updateUrlParams();
    console.log("Input handleInputChange");

    // ทำการ submit ฟอร์มเมื่อค่ามีการเปลี่ยนแปลง
    this.formTarget.submit();
  }

  reset() {
    if (!this.hasFormTarget) {
      console.error("Form target not found!");
      return;
    }

    const form = this.formTarget;

    // รีเซ็ตค่าในฟอร์ม
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
