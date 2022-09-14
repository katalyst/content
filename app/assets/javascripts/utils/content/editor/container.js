import Item from "utils/content/editor/item";

/**
 * @param nodes {NodeList}
 * @returns {Item[]}
 */
function createItemList(nodes) {
  return Array.from(nodes).map((node) => new Item(node));
}

export default class Container {
  /**
   * @param node {Element} content editor list
   */
  constructor(node) {
    this.node = node;
  }

  /**
   * @return {Item[]} an ordered list of all items in the container
   */
  get items() {
    return createItemList(this.node.querySelectorAll("[data-content-index]"));
  }

  /**
   *  @return {String} a serialized description of the structure of the container
   */
  get state() {
    const inputs = this.node.querySelectorAll("li input[type=hidden]");
    return Array.from(inputs)
      .map((e) => e.value)
      .join("/");
  }

  /**
   * Set the index of items based on their current position.
   */
  reindex() {
    this.items.map((item, index) => (item.index = index));
  }

  /**
   * Resets the order of items to their defined index.
   * Useful after an aborted drag.
   */
  reset() {
    this.items.sort(Item.comparator).forEach((item) => {
      this.node.appendChild(item.node);
    });
  }
}