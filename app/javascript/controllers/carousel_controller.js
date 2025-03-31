import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["carousel", "indicator"];

  connect() {
    console.log("Carousel connected");
    this.setupItems();
    this.setupIndicator();
    this.setupObserver();
    this.setCurrentIndex(0);
    this.autoScroll();
  }

  autoScroll() {
    setInterval(() => this.next(), 5000);
  }

  next() {
    this.scrollToElement(this.getNextElement());
  }

  prev() {
    this.scrollToElement(this.getPrevElement());
  }

  scrollToElement(element) {
    const scrollPosition = element.offsetLeft - this.carouselTarget.offsetLeft;
    this.carouselTarget.scrollTo({ behavior: "smooth", left: scrollPosition });
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
        "bg-base-300",
        "size-2",
        "rounded-full",
        "transition-all",
        "hover:cursor-pointer"
      );
      span.dataset.action = "click->carousel#scrollToElementByIndicator";
      span.dataset.index = idx;
      this.indicatorTarget.append(span);
    });
  }

  setupObserver() {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) return;
          this.setCurrentIndex(+entry.target.dataset.index);
        });
      },
      { root: this.carouselTarget, threshold: 1 }
    );

    this.getCarouselItems().forEach((item) => observer.observe(item));
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
    this.getIndicatorItems().forEach((el, i) => {
      el.classList.toggle("bg-black", i === idx);
    });
  }

  scrollToElementByIndicator(event) {
    const index = event.target.dataset.index;
    const element = this.getElementAtIndex(+index);
    this.scrollToElement(element);
  }
}
