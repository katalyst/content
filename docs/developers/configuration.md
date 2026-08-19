---
layout: default
title: Configuration
parent: Developers
nav_order: 7
---

# Configuration

Configure the gem in an initializer:

```ruby
# config/initializers/katalyst_content.rb
Katalyst::Content.configure do |config|
  config.items          = %w[Katalyst::Content::Section Content::Spacer]
  config.themes         = %w[light dark]
  config.base_controller = "Admin::BaseController"
end
```

## Items and presentation

* **`items`** — the item types available in the editor's new-item dialog.
  Defaults to the built-in types. See [custom items](items/custom-items).
* **`themes`** — theme names offered on items (default `light dark`).
  `default_theme` sets the theme assumed when none is selected.
* **`heading_styles`** — heading style options (default `none default`).

## Images

* **`image_mime_types`** — content types accepted by image attachments
  (default PNG, GIF, JPEG, WebP).
* **`max_image_size`** — maximum image size in megabytes (default 20).

These are conventions for your item validations rather than enforced
globally — built-in items validate against them, and custom items can too;
they're available as `config` in the class body:

```ruby
validates :image,
          content_type: config.image_mime_types,
          size:         { less_than: config.max_image_size.megabytes }
```

## Editor integration

* **`base_controller`** — the class name the engine's editor controllers
  inherit from (default `"ApplicationController"`). This is how the editor's
  item endpoints pick up your application's authentication and authorization:
  point it at your admin base controller. If you leave the default, item
  editing is only as protected as your `ApplicationController` — for an
  admin-only editor that almost certainly isn't what you want.
* **`errors_component`** — the ViewComponent used to render validation
  errors in the editor (default
  `"Katalyst::Content::Editor::ErrorsComponent"`). Override to customise
  error presentation.

## Table sanitisation

Pasted table content is sanitised before rendering:

* **`table_sanitizer_allowed_tags`** / **`table_sanitizer_allowed_attributes`**
  — the allowlists applied to table HTML.

For deeper customisation, `Katalyst::Content::TableHelper` exposes the
sanitizer itself:

```ruby
Katalyst::Content::TableHelper.sanitizer = MySanitizer.new
Katalyst::Content::TableHelper.scrubber  = MyScrubber.new
```
