import { Controller } from "@hotwired/stimulus";

export default class StatusBarController extends Controller {
  static targets = ["discard", "revert", "save", "publish"];

  connect() {
    // cache the version's state in the controller on connect
    this.versionState = this.element.dataset.state;
  }

  change(e) {
    if (e.detail && e.detail.hasOwnProperty("dirty")) {
      this.update(e.detail);
    }
  }

  update({ dirty }) {
    if (dirty) {
      this.saveTarget.click();
    } else {
      this.element.dataset.state = this.versionState;
    }
  }
}
