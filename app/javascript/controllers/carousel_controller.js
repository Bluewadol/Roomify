import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["carousel", "indicator"];

  connect() {
    console.log("Carousel connected");
    this.setupItems();
    
    // Only setup indicators and auto-scroll if there are multiple images
    if (this.itemsLength > 1) {
      this.setupIndicator();
      this.setCurrentIndex(0);
      this.autoScroll();
    }
    
    // Ensure the carousel has a proper height
    this.ensureHeight();
  }

  ensureHeight() {
    // Get the parent container height
    const parentHeight = this.element.closest('.h-\\[24rem\\]')?.offsetHeight || 0;
    if (parentHeight > 0) {
      this.element.style.height = `${parentHeight}px`;
      this.carouselTarget.style.height = `${parentHeight}px`;
    }
  }

  autoScroll() {
    this.autoScrollInterval = setInterval(() => this.next(), 5000);
  }

  disconnect() {
    if (this.autoScrollInterval) {
      clearInterval(this.autoScrollInterval);
    }
  }

  next() {
    if (this.itemsLength <= 1) return;
    this.showImage((this.currentIndex + 1) % this.itemsLength);
  }

  prev() {
    if (this.itemsLength <= 1) return;
    this.showImage((this.currentIndex - 1 + this.itemsLength) % this.itemsLength);
  }

  showImage(index) {
    // Hide current image
    const currentImage = this.getCarouselItems()[this.currentIndex];
    if (currentImage) {
      currentImage.classList.remove('opacity-100');
      currentImage.classList.add('opacity-0');
    }
    
    // Show new image
    const newImage = this.getCarouselItems()[index];
    if (newImage) {
      newImage.classList.remove('opacity-0');
      newImage.classList.add('opacity-100');
    }
    
    this.setCurrentIndex(index);
  }

  getNextElement() {
    return this.getElementAtIndex((this.currentIndex + 1) % this.itemsLength);
  }

  getPrevElement() {
    return this.getElementAtIndex(
      (this.currentIndex - 1 + this.itemsLength) % this.itemsLength
    );
  }

  getElementAtIndex(idx) {
    this.setCurrentIndex(idx);
    return this.getCarouselItems()[idx];
  }

  setCurrentIndex(idx) {
    this.currentIndex = idx;
    this.setIndicator(idx);
  }

  setupItems() {
    this.getCarouselItems().forEach((el, idx) => {
      el.dataset.index = idx;
    });
  }

  setupIndicator() {
    if (!this.hasIndicatorTarget) return;

    this.getCarouselItems().forEach((_, idx) => {
      const span = document.createElement("span");
      span.classList.add(
        "bg-white",
        "size-3",
        "rounded-full",
        "transition-all",
        "hover:cursor-pointer",
        "opacity-70",
        "hover:opacity-100"
      );
      span.dataset.action = "click->carousel#scrollToElementByIndicator";
      span.dataset.index = idx;
      this.indicatorTarget.append(span);
    });
  }

  getCarouselItems() {
    const elements = Array.from(this.carouselTarget.children);
    this.itemsLength = elements.length;
    return elements;
  }

  getIndicatorItems() {
    return Array.from(this.indicatorTarget.children);
  }

  getItemIndex(target) {
    return this.getCarouselItems().indexOf(target);
  }

  setIndicator(idx) {
    if (!this.hasIndicatorTarget) return;
    
    this.getIndicatorItems().forEach((el, i) => {
      el.classList.toggle("bg-white", i === idx);
      el.classList.toggle("bg-gray-300", i !== idx);
      el.classList.toggle("opacity-100", i === idx);
      el.classList.toggle("opacity-70", i !== idx);
    });
  }

  scrollToElementByIndicator(event) {
    const index = event.target.dataset.index;
    this.showImage(+index);
  }
}
