import { Controller } from "@hotwired/stimulus";

import Item from "./item";
import Container from "./container";
import RulesEngine from "./rules_engine";

export default class ContainerController extends Controller {
  static targets = ["container"];

  // Caution: connect is called on attachment, but also on morph/render
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

  drop(event) {
    this.container.reindex(); // set indexes before calculating previous

    const item = getEventItem(event);
    const previous = item.previousItem;

    let delta = 0;
    if (previous === undefined) {
      // if previous does not exist, set depth to 0
      delta = -item.depth;
    } else if (
      previous.isLayout &&
      item.nextItem &&
      item.nextItem.depth > previous.depth
    ) {
      // if previous is a layout and next is a child of previous, make item a child of previous
      delta = previous.depth - item.depth + 1;
    } else {
      // otherwise, make item a sibling of previous
      delta = previous.depth - item.depth;
    }

    item.traverse((child) => {
      child.depth += delta;
    });

    this.#update();
    event.preventDefault();
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
      const engine = new RulesEngine();
      this.container.items.forEach((item) => engine.normalize(item));
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
