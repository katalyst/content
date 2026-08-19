---
layout: default
title: Search
parent: Developers
nav_order: 5
---

# Search

Content is stored as structured items, so it can't be indexed by pointing a
search engine at a column. Instead, the gem provides a plain-text projection
of published content that you can feed to whatever search integration your
application uses.

## Plain text projection

Each item implements `to_plain_text`, returning a text representation of the
item — or `nil` when the item is hidden. Versions join the visible tree into
a single string, and containers delegate to their versions:

```ruby
page.published_text # plain text of the published version, or nil
page.draft_text     # plain text of the draft version
```

Custom items should implement `to_plain_text` if they carry searchable
content. Returning `super` includes the heading (when shown and visible);
return `nil` if the item should not contribute to search:

```ruby
def to_plain_text
  [super, description.to_plain_text].compact.join("\n") if visible?
end
```

## Indexing

Index `published_text` so search reflects what visitors can see — draft
changes stay out of the index until published. For example, with
[pg_search](https://github.com/Casecommons/pg_search) multisearch:

```ruby
class Page < ApplicationRecord
  include Katalyst::Content::Container
  include PgSearch::Model

  multisearchable against:   %i[published_text],
                  if:        :published?,
                  update_if: :search_content_changed?

  def search_content_changed?
    saved_change_to_attribute?(:title) ||
      saved_change_to_attribute?(:published_version_id)
  end
end
```

Two details worth noting:

* `published_text` is computed from the version tree, not stored on the
  record, so the search library can't detect when it changes. Publishing
  updates `published_version_id`, so use that as the re-index trigger
  (`update_if` above).
* `if: :published?` keeps unpublished records out of the index. Note that
  `published?` is true for containers in the draft state too — they have a
  live published version, and it's that version's text that is indexed.
