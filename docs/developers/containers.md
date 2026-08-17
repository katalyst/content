---
layout: default
title: Containers
parent: Developers
nav_order: 2
---

# Containers

A container is a model in your application that holds content — see
[getting started](getting-started) for the migration and model setup. This
page describes how versioning behaves once a container is set up.

## Versions

Items belong to the container, but the *structure* of the content — which
items appear, in what order, at what depth — is stored on versions as a list
of nodes. Each container points at two versions:

* `draft_version` — the version editors are working on.
* `published_version` — the version rendered to visitors.

Saving structural changes is copy-on-write: the persisted draft is duplicated
into a new version, so the published version is never modified in place.

## States

Containers expose a `state` attribute, maintained automatically — it can't be
assigned directly, use the lifecycle methods below.

* `unpublished` — no published version. New containers start here, as do
  containers that have been unpublished.
* `draft` — published, with newer saved changes that are not yet live.
* `published` — the draft and published versions are the same.

Note that `published?` is true for both the `published` and `draft` states —
it answers "is there a live version?", not "is everything published?".

Matching scopes are available for querying and filtering:

```ruby
Page.published    # live, with no unpublished changes
Page.draft        # live, with unpublished changes
Page.unpublished  # not live
Page.state(%w[draft published])
Page.order_by_state(:asc)
```

## Lifecycle

```ruby
page.publish!   # promote the draft version to published
page.revert!    # discard the draft, returning to the published version
page.unpublish! # remove the published version; visitors no longer see content
```

Structural updates from the editor arrive through `items_attributes=`, which
conforms to the `accepts_nested_attributes_for` interface so it works with
Rails form helpers. Assigning it builds a new draft version:

```ruby
page.items_attributes = [{ id: item.id, index: 0, depth: 0 }]
page.save! # persists the new draft version
```

## Garbage collection

Containers clean up after themselves: when a container is updated, versions
other than the current draft and published version are removed, and items no
longer referenced by either are removed after a two-hour grace period (which
allows for in-progress editing). Prior versions are not retained — reverting
returns to the published version, not to arbitrary points in history.
