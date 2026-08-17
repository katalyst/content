---
layout: default
title: Items
parent: Developers
nav_order: 3
has_children: true
---

# Items

Items are the typed blocks that make up content. They are stored as STI rows
in the `katalyst_content_items` table, arranged in a tree: each item has an
`index` (position) and `depth` (nesting), managed by the editor.

Every item has a `heading` (with a configurable `heading_style`, including
`none` to hide it), an optional [theme](themes), and a `visible` flag —
hidden items stay in the draft but are not rendered in the frontend.

## Built-in item types

* **Content** — rich text, edited with Trix.
* **Figure** — an image attachment with alt text and a caption.
* **Table** — tabular content pasted or imported as HTML, sanitised on
  assignment.
* **Section, Group, Column, Aside** — layout items that contain and arrange
  their nested children.

The item types available in the editor are set by `config.items`; see
[custom items](custom-items) for registering your own.

## Rendering

Each item type provides two partials, resolved from the model's partial path:
`_content.html.erb` renders the item in the frontend, and
`_content.html+form.erb` renders the item's form in the editor. Frontend
rendering wraps each item using `content_item_tag`, which applies the item's
theme and visibility.
