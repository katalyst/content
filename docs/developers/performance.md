---
layout: default
title: Performance
parent: Developers
nav_order: 6
---

# Performance

Rendering content involves a tree of typed items, each of which may carry
attachments, rich text, or detail records. The gem's design keeps this cheap:
the item tree loads in a single query, and rendered output is fragment
cached, keyed on the content version.

## Fragment caching

`render_content` wraps its output in a Rails fragment cache keyed on the
version:

```ruby
cache version do
  # render item tree
end
```

Versions are effectively immutable: copy-on-write editing builds a new draft
version, and publishing promotes it. A published version's cache entry is
written once — on the first render after publishing — and served from cache
after that. Invalidation is automatic, because a new publish means a new
version and therefore a new cache key. Draft previews are also cached, keyed
on the draft version's `updated_at`, so each saved draft renders fresh.

This requires a real cache store in production — for example:

```ruby
# config/environments/production.rb
config.cache_store = :mem_cache_store # with the dalli gem
```

In development the cache is disabled by default; run `rails dev:cache` to
toggle it on when testing caching behaviour.

### Deploying item partial changes

Item partials are selected dynamically at render time, so Rails' template
dependency digest can't see them — editing an item partial does **not**
invalidate existing cache entries. After deploying partial changes, expire
the cache (or republish affected content) if the change must appear on
already-published pages immediately.

## N+1 queries

A version loads its complete item tree in one query, regardless of item
count. Per-item associations — rich text, attachments, detail records — are
loaded lazily, one query per item, when the item is first rendered. Note
that default scopes such as `with_rich_text_content` on item classes do
**not** apply here: items load through the container's base-class
association, so association loading is deferred to render time.

For frontend rendering this is absorbed by the fragment cache: the N+1 cost
is paid once per published version, not per request.

The cost is real on paths that bypass the cache:

* **Plain text projection** — `published_text` walks every item's
  `to_plain_text`, loading rich text per item. Fine for indexing a page on
  publish; noticeable when reindexing every container in bulk.
* **Custom rendering** that iterates `version.items` or `version.tree`
  outside `render_content`.

Keep bulk operations off the request path (background jobs), and keep
`to_plain_text` implementations free of queries beyond the item's own
associations.
