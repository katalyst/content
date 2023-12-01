import { Controller } from "@hotwired/stimulus";
import "trix";

// Note, action_text 7.1.2 changes how Trix is bundled and loaded. This
// seems to have broken the default export from trix. This is a workaround
// that relies on the backwards compatibility of the old export to window.Trix.
const Trix = window.Trix;

// Stimulus controller doesn't do anything, but having one ensures that trix
// will be lazy loaded when a trix-editor is added to the dom.
export default class TrixController extends Controller {
  trixInitialize(e) {
    // noop, useful as an extension point for registering behaviour on load
  }

  trixPaste(e) {
    const pastedHtml = e.paste.html;
    const pasted = document.createElement("div");
    pasted.innerHTML = pastedHtml;
    if (pasted.querySelector("img")) {
      console.debug("please do not paste this image again");
      // Undo the paste
      e.target.editor.undo();
    }
  }
}

// Add H4 as an acceptable tag
Trix.config.blockAttributes["heading4"] = {
  tagName: "h4",
  terminal: true,
  breakOnReturn: true,
  group: false,
};

// Remove H1 from trix list of acceptable tags
delete Trix.config.blockAttributes.heading1;

/**
 * Allow users to enter path and fragment URIs which the input[type=url] browser
 * input does not permit. Uses a permissive regex pattern which is not suitable
 * for untrusted use cases.
 */
const LINK_PATTERN = "(https?|mailto:|tel:|/|#).*?";

/**
 * Customize default toolbar:
 *
 * * headings: h4 instead of h1
 * * links: use type=text instead of type=url
 *
 * @returns {String} toolbar html fragment
 */
Trix.config.toolbar.getDefaultHTML = () => {
  const { lang } = Trix.config;
  return `
<div class="trix-button-row">
  <span class="trix-button-group trix-button-group--text-tools" data-trix-button-group="text-tools">
    <button type="button" class="trix-button trix-button--icon trix-button--icon-bold" data-trix-attribute="bold" data-trix-key="b" title="${lang.bold}" tabindex="-1">${lang.bold}</button>
    <button type="button" class="trix-button trix-button--icon trix-button--icon-italic" data-trix-attribute="italic" data-trix-key="i" title="${lang.italic}" tabindex="-1">${lang.italic}</button>
    <button type="button" class="trix-button trix-button--icon trix-button--icon-strike" data-trix-attribute="strike" title="${lang.strike}" tabindex="-1">${lang.strike}</button>
    <button type="button" class="trix-button trix-button--icon trix-button--icon-link" data-trix-attribute="href" data-trix-action="link" data-trix-key="k" title="${lang.link}" tabindex="-1">${lang.link}</button>
  </span>
  <span class="trix-button-group trix-button-group--block-tools" data-trix-button-group="block-tools">
    <button type="button" class="trix-button trix-button--icon trix-button--icon-heading-1" data-trix-attribute="heading4" title="${lang.heading1}" tabindex="-1">${lang.heading1}</button>
    <button type="button" class="trix-button trix-button--icon trix-button--icon-quote" data-trix-attribute="quote" title="${lang.quote}" tabindex="-1">${lang.quote}</button>
    <button type="button" class="trix-button trix-button--icon trix-button--icon-code" data-trix-attribute="code" title="${lang.code}" tabindex="-1">${lang.code}</button>
    <button type="button" class="trix-button trix-button--icon trix-button--icon-bullet-list" data-trix-attribute="bullet" title="${lang.bullets}" tabindex="-1">${lang.bullets}</button>
    <button type="button" class="trix-button trix-button--icon trix-button--icon-number-list" data-trix-attribute="number" title="${lang.numbers}" tabindex="-1">${lang.numbers}</button>
    <button type="button" class="trix-button trix-button--icon trix-button--icon-decrease-nesting-level" data-trix-action="decreaseNestingLevel" title="${lang.outdent}" tabindex="-1">${lang.outdent}</button>
    <button type="button" class="trix-button trix-button--icon trix-button--icon-increase-nesting-level" data-trix-action="increaseNestingLevel" title="${lang.indent}" tabindex="-1">${lang.indent}</button>
  </span>
  <span class="trix-button-group trix-button-group--file-tools" data-trix-button-group="file-tools">
    <button type="button" class="trix-button trix-button--icon trix-button--icon-attach" data-trix-action="attachFiles" title="${lang.attachFiles}" tabindex="-1">${lang.attachFiles}</button>
  </span>
  <span class="trix-button-group-spacer"></span>
  <span class="trix-button-group trix-button-group--history-tools" data-trix-button-group="history-tools">
    <button type="button" class="trix-button trix-button--icon trix-button--icon-undo" data-trix-action="undo" data-trix-key="z" title="${lang.undo}" tabindex="-1">${lang.undo}</button>
    <button type="button" class="trix-button trix-button--icon trix-button--icon-redo" data-trix-action="redo" data-trix-key="shift+z" title="${lang.redo}" tabindex="-1">${lang.redo}</button>
  </span>
</div>
<div class="trix-dialogs" data-trix-dialogs>
  <div class="trix-dialog trix-dialog--link" data-trix-dialog="href" data-trix-dialog-attribute="href">
    <div class="trix-dialog__link-fields">
      <input type="text" name="href" pattern="${LINK_PATTERN}" class="trix-input trix-input--dialog" placeholder="${lang.urlPlaceholder}" aria-label="${lang.url}" required data-trix-input>
      <div class="trix-button-group">
        <input type="button" class="trix-button trix-button--dialog" value="${lang.link}" data-trix-method="setAttribute">
        <input type="button" class="trix-button trix-button--dialog" value="${lang.unlink}" data-trix-method="removeAttribute">
      </div>
    </div>
  </div>
</div>
`;
};

/**
 * If the <trix-editor> element is in the HTML when Trix loads, then Trix will have already injected the toolbar content
 * before our code gets a chance to run. Fix that now.
 *
 * Note: in Trix 2 this is likely to no longer be necessary.
 */
document.querySelectorAll("trix-toolbar").forEach((e) => {
  e.innerHTML = Trix.config.toolbar.getDefaultHTML();
});
