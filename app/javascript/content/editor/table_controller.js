import { Controller } from "@hotwired/stimulus";

export default class TableController extends Controller {
  static targets = ["content", "input"];

  constructor(config) {
    super(config);

    this.observer = new MutationObserver(this.change);
  }

  connect() {
    this.observer.observe(this.contentTarget, {
      attributes: true,
      childList: true,
      characterData: true,
      subtree: true
    });
  }

  disconnect() {
    this.observer.disconnect();
  }

  change = (mutations) => {
    this.inputTarget.value = this.contentTarget.innerHTML;
  }

  update = () => {
    this.element.closest("form").querySelector("button[data-action='update']").click();
  }

  paste = (e) => {
    e.preventDefault();

    this.inputTarget.value = e.clipboardData.getData("text/html");

    this.update();
  }
}
