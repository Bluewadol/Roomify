import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    // Initial height adjustment
    this.adjustHeight();
  }

  adjustHeight() {
    // Reset height to auto to get the correct scrollHeight
    this.element.style.height = 'auto';
    
    // Set the height to match the content
    this.element.style.height = this.element.scrollHeight + 'px';
  }
} 