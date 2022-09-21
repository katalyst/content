import { Controller } from "@hotwired/stimulus";
import Trix from "trix";

export default class TrixController extends Controller {
  trixInitialize(event) {
    const { toolbarElement } = event.target;
    const input = toolbarElement.querySelector("input[name=href]");

    permitURILinks(input);
  }
}

/**
 * Allow users to enter path and fragment URIs which the input[type=url] browser
 * input does not permit. Uses a permissive regex pattern which is not suitable
 * for untrusted use cases.
 */
function permitURILinks(input) {
  // Change the input type from "url" to "text"
  input.type = "text";

  // restrict acceptable inputs
  input.pattern = "(https?|/|#).*?";
}
