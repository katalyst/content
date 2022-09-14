import { Controller } from "@hotwired/stimulus";

import Item from "utils/content/editor/item";
import Container from "utils/content/editor/container";
import RulesEngine from "utils/content/editor/rules-engine";

export default class ContainerController extends Controller {
  static targets = ["container"];
  static values = {
    maxDepth: Number,
  };

  connect() {
    this.state = this.container.state;

    this.reindex();
  }

  get container() {
    return new Container(this.containerTarget);
  }

  reindex() {
    this.container.reindex();
    this.#update();
  }

  reset() {
    this.container.reset();
  }

  remove(event) {
    const item = getEventItem(event);

    item.node.remove();

    this.#update();
    event.preventDefault();
  }

  nest(event) {
    const item = getEventItem(event);

    item.traverse((child) => {
      child.depth += 1;
    });

    this.#update();
    event.preventDefault();
  }

  deNest(event) {
    const item = getEventItem(event);

    item.traverse((child) => {
      child.depth -= 1;
    });

    this.#update();
    event.preventDefault();
  }

  collapse(event) {
    const item = getEventItem(event);

    item.collapse();

    this.#update();
    event.preventDefault();
  }

  expand(event) {
    const item = getEventItem(event);

    item.expand();

    this.#update();
    event.preventDefault();
  }

  /**
   * Re-apply rules to items to enable/disable appropriate actions.
   */
  #update() {
    // debounce requests to ensure that we only update once per tick
    this.updateRequested = true;
    setTimeout(() => {
      if (!this.updateRequested) return;

      this.updateRequested = false;
      const engine = new RulesEngine(this.maxDepthValue);
      this.container.items.forEach((item) => engine.update(item));

      this.#notifyChange();
    }, 0);
  }

  #notifyChange() {
    this.dispatch("change", {
      bubbles: true,
      prefix: "content",
      detail: { dirty: this.#isDirty() },
    });
  }

  #isDirty() {
    return this.container.state !== this.state;
  }
}

function getEventItem(event) {
  return new Item(event.target.closest("[data-content-item]"));
}
