---
layout: default
title: Themes
parent: Items
grand_parent: Developers
nav_order: 2
---

# Themes

Every item has an optional `theme`, chosen from `config.themes` (default
`light dark`). Themes are rendered as `data-content-theme` attributes in the
frontend, and CSS keyed on those attributes swaps the palette — the gem never
hard-codes colours into markup. (You may see `backgrounds` in older projects;
it's a legacy alias for `themes`.)

## Defaults and inheritance

Editors only set a theme where the design changes; a blank theme means
"inherit". When the item tree is built for rendering, an item without an
explicit theme takes its parent's theme, and items at the root take
`config.default_theme` (the first configured theme unless set). Every item
therefore has an effective theme at render time, without editors having to
theme each item individually.

## Grouping and spacing

`render_content` groups adjacent items that share a theme into a single
`.content-items` wrapper carrying the theme:

```html
<div class="content-items" data-content-theme="light">...</div>
<div class="content-items" data-content-theme="dark">...</div>
```

The gem's frontend CSS spaces these with custom properties:

* Items *within* a group are separated by `--content-block-gap` margins.
* Themed groups get `--content-block-gutter` block padding, so a theme
  change reads as a distinct band with more space around it than between
  same-theme items.

Both derive from `--content-gap` and `--content-gutter`, which projects
override to set the rhythm of content pages — globally, or scoped:

```css
.content--page {
  --content-gap: var(--space-l);
  --content-gutter: var(--space-l);
}
```

When a group is rendered inside a themed parent, it only carries
`data-content-theme` if its theme differs from the parent's, so backgrounds
aren't repainted unnecessarily.

## Styling a theme

Elements with `data-content-theme` take their background and text colour from
custom properties, and each theme is a CSS block defining those properties.
The gem ships minimal defaults for `light` and `dark`; projects redefine them
with their palette:

```css
[data-content-theme="dark"] {
  --text-color: white;
  --heading-color: white;
  --background: var(--color-secondary);
  --link-color: white;
}
```

Because the theme block is just a scope, any component tokens can be re-keyed
per theme — for example, giving buttons theme-appropriate colours:

```css
[data-content-theme] .button {
  --button-bg: var(--content-button-bg);
  --button-color: var(--content-button-color);
}

[data-content-theme="dark"] {
  --content-button-bg: white;
  --content-button-color: black;
}
```

## Adding themes

Register the theme name, then style it:

```ruby
# config/initializers/katalyst_content.rb
Katalyst::Content.configure do |config|
  config.themes += %w[off-white]
end
```

```css
[data-content-theme="off-white"] {
  --text-color: var(--color-dark);
  --background: var(--color-tint);
  --link-color: var(--color-dark);
}
```

The new theme appears in the editor's theme select, and themed items show a
theme indicator in the editor tree.
