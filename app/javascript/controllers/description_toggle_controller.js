import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["toggleButton"];
  static values = {
    maxLines: Number
  };

  connect() {
    console.log("Description toggle connected");
    this.descriptionElement = this.element.querySelector('.description-content');
    this.isExpanded = false;
    
    // Initial check
    this.checkHeight();
    
    // Set up a MutationObserver to watch for content changes
    this.setupObserver();
  }
  
  setupObserver() {
    // Create a MutationObserver to watch for changes to the description content
    this.observer = new MutationObserver(() => {
      console.log("Content changed, rechecking height");
      this.checkHeight();
    });
    
    // Start observing the description element for changes
    if (this.descriptionElement) {
      this.observer.observe(this.descriptionElement, {
        childList: true,
        characterData: true,
        subtree: true
      });
    }
  }
  
  disconnect() {
    // Clean up the observer when the controller is disconnected
    if (this.observer) {
      this.observer.disconnect();
    }
  }

  checkHeight() {
    if (!this.descriptionElement) return;
    
    // Check if there's any content
    const hasContent = this.descriptionElement.textContent.trim().length > 0;
    
    // Get the line height in pixels
    const lineHeight = parseInt(window.getComputedStyle(this.descriptionElement).lineHeight) || 20;
    const maxHeight = lineHeight * 3; // 3 lines
    
    console.log("Content height:", this.descriptionElement.scrollHeight);
    console.log("Max height:", maxHeight);
    console.log("Has content:", hasContent);
    
    if (hasContent && this.descriptionElement.scrollHeight > maxHeight) {
      console.log("Content is long, showing toggle button");
      // Apply max height and show toggle button
      this.collapseContent();
      this.toggleButtonTarget.classList.remove('hidden');
    } else {
      console.log("Content is short or empty, hiding toggle button");
      // Content is short or empty, hide toggle button
      this.descriptionElement.style.maxHeight = 'none';
      this.descriptionElement.style.overflow = 'visible';
      this.toggleButtonTarget.classList.add('hidden');
    }
  }

  toggle(event) {
    event.preventDefault();
    console.log("Toggle clicked, current state:", this.isExpanded);
    
    if (this.isExpanded) {
      this.collapseContent();
    } else {
      this.expandContent();
    }
  }
  
  expandContent() {
    this.descriptionElement.style.maxHeight = 'none';
    this.descriptionElement.style.overflow = 'visible';
    this.toggleButtonTarget.innerHTML = 'Hide';
    this.isExpanded = true;
    console.log("Content expanded");
  }
  
  collapseContent() {
    // Force a small height to ensure content is hidden
    this.descriptionElement.style.maxHeight = '3em';
    this.descriptionElement.style.overflow = 'hidden';
    this.toggleButtonTarget.innerHTML = 'See All';
    this.isExpanded = false;
    console.log("Content collapsed");
  }
} 