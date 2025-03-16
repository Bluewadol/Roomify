import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["progress"];

  connect() {
    this.element.classList.remove("hidden");
    this.startProgress();
    this.timeout = setTimeout(() => {
      this.close();
    }, 3000);
  }

  startProgress() {
    if (this.hasProgressTarget) {
      this.progressTarget.style.width = "100%";
      this.progressTarget.style.transition = "width 3s linear";
      setTimeout(() => {
        this.progressTarget.style.width = "0%";
      }, 50);
    }
  }

  close() {
    clearTimeout(this.timeout);
    this.element.classList.add("opacity-0", "transition-opacity", "duration-1000");
    setTimeout(() => {
      this.element.remove();
    }, 1000);
  }
}
