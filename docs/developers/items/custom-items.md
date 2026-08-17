---
layout: default
title: Custom items
parent: Items
grand_parent: Developers
nav_order: 1
---

# Custom items

Add your own item types by subclassing `Katalyst::Content::Item` and
registering the type in an initializer:

```ruby
# config/initializers/katalyst_content.rb
Katalyst::Content.configure do |config|
  config.items = %w[
    Katalyst::Content::Section
    Katalyst::Content::Content
    Content::Spacer
  ]
end
```

Provide the two partials for the new type — frontend and editor form:

```erb
<%# app/views/content/spacers/_spacer.html.erb (frontend) %>
<%= content_item_tag(spacer) do %>
  ...
<% end %>
```

```erb
<%# app/views/content/spacers/_spacer.html+form.erb (editor form) %>
<%= form.content_heading_fieldset %>
<%= form.content_theme_field %>
```

The editor's form builder provides fields for the shared item attributes —
`content_heading_fieldset`, `content_theme_field`, `content_url_field`, and
friends — and includes the
[GOV.UK form builder](https://govuk-form-builder.netlify.app/), so
`govuk_text_field` and the other `govuk_*` helpers are available for your own
attributes.

What goes in the model depends on how much data the item needs.

## Simple items

Most item types need nothing beyond the shared STI columns — `heading`,
`heading_style`, `theme`, `visible`. Type-specific presentation settings can
be added without migrations using `style_attributes`, which maps ActiveModel
attributes into the shared `style` JSON column, complete with accessors and
validation:

```ruby
module Content
  class Spacer < Katalyst::Content::Item
    HEIGHTS = %w[small medium large].freeze

    style_attributes do
      attribute :height, :string
    end

    validates :height, presence: true, inclusion: { in: HEIGHTS }

    def self.permitted_params
      super + %i[height]
    end
  end
end
```

## Media items

Items can carry files and formatted text using standard Rails features —
Active Storage attachments and Action Text rich text:

```ruby
module Content
  class ImageBanner < Katalyst::Content::Item
    has_one_attached :image
    has_rich_text :subtitle

    validates :image,
              presence:     true,
              content_type: config.image_mime_types,
              size:         { less_than: config.max_image_size.megabytes }

    default_scope { with_attached_image }

    def self.permitted_params
      super + %i[image subtitle]
    end
  end
end
```

The gem provides everything these need. In particular, editing published
content is copy-on-write — draft changes duplicate items rather than editing
them in place — and attachments and rich text are duplicated automatically,
including changes an editor has submitted but not yet published: pending
uploads, cleared attachment fields, and attachments marked for destruction
via nested attributes.

## Complex items

When an item needs structured data that doesn't fit the shared table or the
`style` JSON — typed columns, foreign keys, its own validations — store it in
a separate table accessed via a `has_one` association:

```ruby
module Content
  class DonationForm < Katalyst::Content::Item
    has_one :donation_form_detail, as: :donation_formable, autosave: true, dependent: :destroy
    accepts_nested_attributes_for :donation_form_detail, update_only: true
    duplicates_association :donation_form_detail

    def self.permitted_params
      super + [DonationFormDetail.permitted_params]
    end
  end
end
```

### Duplication

Complex items take on a responsibility that simple and media items get for
free. Copy-on-write editing duplicates items with `dup`, and the gem cannot
know about your detail table — without help, the duplicate would silently
lose its detail record the next time an editor changes the item. The
`duplicates_association` declaration closes that gap: declared records are
copied with `dup`, carrying unsaved nested-attribute edits and dropping
records marked for destruction. `has_many` associations are supported the
same way.

Items do not need to define `initialize_dup` unless they copy state that is
not an attachment, rich text, or a declared association. Only `dup` is
supported; `clone` is not.

The `Koi/DuplicatesAssociation` cop in
[rubocop-katalyst](https://github.com/katalyst/rubocop-katalyst) detects owned
associations (`dependent: :destroy` plus autosave or nested attributes) that
are missing a `duplicates_association` declaration.

### Testing

Attachment and rich-text duplication are library features with their own test
coverage — you don't need to re-test them per model. Detail records are
project code, so give each an integration-level `#dup` spec, and consider a
whole-of-dup test that duplicates a fully populated item and saves the copy —
a broken dup silently loses content on the user's next edit.

```ruby
describe "#dup" do
  subject(:form) { create(:content_donation_form, container: page) }

  it "copies the detail record" do
    expect(form.dup.donation_form_detail).to be_new_record
      .and have_attributes(form.donation_form_detail.attributes.except("id", "created_at", "updated_at"))
  end

  it "produces a complete, saveable copy" do
    copy = form.dup
    copy.save!
    expect(copy.donation_form_detail).to be_persisted
  end
end
```

## Duplication outside items

Any model that duplicates copy-on-write can reuse the gem's duplication
behaviour, either by including the concerns
(`Katalyst::Content::DuplicatesAttachments`, `DuplicatesRichText`,
`DuplicatesAssociations`) or by calling the helper classes directly:

```ruby
def initialize_dup(source)
  super

  Katalyst::Content::DuplicatesAttachments::DupOne.new(:image).apply(source, self)
  Katalyst::Content::DuplicatesRichText::DupRichText.new(:description).apply(source, self)
end
```
