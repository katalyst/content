import { Controller } from "@hotwired/stimulus";

const EDITOR = `
<div class="content--editor--table-editor"
   contenteditable="true"
   data-content--editor--table-target="content"
   data-action="paste->content--editor--table#paste"
   id="item-content-field">
</div>`;

export default class TableController extends Controller {
  static targets = ["input", "update"];

  constructor(config) {
    super(config);

    this.observer = new MutationObserver(this.change);
  }

  connect() {
    const template = document.createElement("TEMPLATE");
    template.innerHTML = EDITOR;
    this.content = template.content.firstElementChild;
    this.content.innerHTML = this.inputTarget.value;
    this.content.className += ` ${this.inputTarget.className}`;
    this.inputTarget.insertAdjacentElement("beforebegin", this.content);
    this.inputTarget.hidden = true;

    this.observer.observe(this.content, {
      attributes: true,
      childList: true,
      characterData: true,
      subtree: true,
    });
  }

  disconnect() {
    this.observer.disconnect();
    this.content.remove();
    delete this.content;
  }

  change = (mutations) => {
    this.inputTarget.value = this.table?.outerHTML;
  };

  update = () => {
    this.updateTarget.click();
  };

  paste = (e) => {
    if (e.clipboardData.getData("text/html").indexOf("<table") === -1) return;

    e.preventDefault();

    this.inputTarget.value = e.clipboardData.getData("text/html");

    this.update();
  };

  /**
   * @returns {HTMLTableElement} The table element from the content target
   */
  get table() {
    return this.content.querySelector("table");
  }
}
