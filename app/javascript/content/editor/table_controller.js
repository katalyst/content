import { Controller } from "@hotwired/stimulus";

export default class TableController extends Controller {
  static targets = ["content", "input", "update"];

  constructor(config) {
    super(config);

    this.observer = new MutationObserver(this.change);
  }

  connect() {
    this.observer.observe(this.contentTarget, {
      attributes: true,
      childList: true,
      characterData: true,
      subtree: true,
    });
  }

  disconnect() {
    this.observer.disconnect();
  }

  change = (mutations) => {
    this.inputTarget.value = this.table.outerHTML;
  };

  update = () => {
    this.updateTarget.click();
  };

  paste = (e) => {
    e.preventDefault();

    this.inputTarget.value = e.clipboardData.getData("text/html");

    this.update();
  };

  /**
   * @returns {HTMLTableElement} The table element from the content target
   */
  get table() {
    return this.contentTarget.querySelector("table");
  }
}
