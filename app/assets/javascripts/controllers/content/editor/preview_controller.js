import { Controller } from "@hotwired/stimulus";

export default class PreviewController extends Controller {
  preview(e) {
    const iframeContent = this.element.contentDocument;

    iframeContent.querySelectorAll(".preview-component").forEach((e) => {
      e.classList.remove("preview-component");
    });

    const previewComponent = iframeContent.querySelector(
      `[data-content-id='${e.detail.id}']`
    );

    previewComponent.classList.add("preview-component");
    previewComponent.scrollIntoView({ behavior: "smooth" });
  }
}
