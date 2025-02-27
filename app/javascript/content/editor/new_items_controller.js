import { Controller } from "@hotwired/stimulus";

export default class NewItemsController extends Controller {
  static targets = ["inlineButton"];

  connect() {
    this.form.addEventListener("mousemove", this.move);
  }

  disconnect() {
    this.form?.removeEventListener("mousemove", this.move);
    delete this.currentItem;
  }

  open(e) {
    e.preventDefault();
    this.dialog.showModal();
  }

  close(e) {
    e.preventDefault();
    this.dialog.close();
  }

  /**
   * Add the selected item to the DOM at the current position or the end of the list.
   */
  add(e) {
    e.preventDefault();

    const template = e.target.querySelector("template");
    const item = template.content.querySelector("li").cloneNode(true);
    const target = this.currentItem;

    if (target) {
      target.insertAdjacentElement("beforebegin", item);
    } else {
      this.list.insertAdjacentElement("beforeend", item);
    }

    this.toggleInlineButton(false);
    this.dialog.close();

    requestAnimationFrame(() => {
      item.querySelector(`[value="edit"]`).click();
    });
  }

  morph(e) {
    e.preventDefault();
    this.dialog.close();
  }

  move = debounce((e) => {
    if (
      document.elementFromPoint(e.clientX, e.clientY) ===
      this.inlineButtonTarget
    ) {
      return;
    }

    if (this.dialog.open) {
      return;
    }

    this.currentItem = this.getCurrentItem(e);

    this.toggleInlineButton();
  });

  toggleInlineButton(show = !!this.currentItem) {
    if (show) {
      this.inlineButtonTarget.style.top = `${this.currentItem.offsetTop}px`;
      this.inlineButtonTarget.toggleAttribute("hidden", false);
    } else {
      this.inlineButtonTarget.toggleAttribute("hidden", true);
    }
  }

  get dialog() {
    return this.element.querySelector("dialog");
  }

  /**
   * @returns {HTMLFormElement}
   */
  get form() {
    return this.element.closest("form");
  }

  /**
   * @returns {HTMLUListElement,null}
   */
  get list() {
    return this.form.querySelector(`[data-controller="content--editor--list"]`);
  }

  /**
   * @param {MouseEvent} e
   * @returns {HTMLLIElement,null}
   */
  getCurrentItem(e) {
    const item = document.elementFromPoint(e.clientX, e.clientY).closest("li");
    if (!item) return null;

    const bounds = item.getBoundingClientRect();
    const position = e.clientY;
    if (e.clientY - bounds.y <= 8) {
      return item;
    } else if (bounds.y + bounds.height - e.clientY <= 8) {
      return item.nextElementSibling;
    } else {
      return null;
    }
  }
}

function debounce(f, timeout = 120) {
  let timer = null;
  return (e) => {
    if (timer) clearTimeout(timer);
    timer = setTimeout(() => {
      timer = null;
      f(e);
    }, timeout);
  };
}
