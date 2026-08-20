---
name: content-module-audit
description: Audit a single Rails model that includes Katalyst::Content::Container against Katalyst Content best practices. Use when asked to audit, lint, or review a content module (e.g. Page) in a Rails app. Checks model and schema setup, frontend routing, previews, search integration, and test coverage. Reports findings; does not change code.
---

# Content Module Audit

Lint one content module — a Rails model that includes
`Katalyst::Content::Container` — against the documented best practices.
Think of this as a context-aware rubocop: it checks behaviour and wiring, not
style, and it reports rather than fixes.

Out of scope (project- or gem-level concerns, covered elsewhere): custom item
types, the admin editor contract, `Katalyst::Content.config`, themes, and
cache store setup. One module per run.

## 1. Select the module

If the user named a model, use it. Otherwise find candidates:

```
grep -rln "include Katalyst::Content::Container" app/models
```

If there are multiple candidates, ask the user which one to audit. If there
are none, report that the app has no content modules and stop.

## 2. Establish context: read the docs first

Best practices live in this skill's own repository — the skill ships in
katalyst/content, alongside the documentation it audits against:

1. Resolve the skill's real location (follow the symlink if it was
   installed via one); the docs are under `docs/developers/` in the same
   repository.
2. Check the repository is on `main` and up to date (`git status`,
   `git log -1 --format=%cd`). If it is behind, on another branch, or dirty,
   ask the user before running any git commands that change its state
   (fetch, pull, checkout) — never assume.
3. Fall back to the published site (https://katalyst.github.io/content/)
   only if the local repository is unreadable or the user declines updating
   a stale one.

If the docs have already been located this session (e.g. by
`content-audit`), reuse them and skip the steps above.

Read these before auditing (paths relative to the repository root):

| Doc | Establishes |
| --- | --- |
| `docs/developers/getting-started.md` | container migration and model setup |
| `docs/developers/containers.md` | versions, states, lifecycle semantics |
| `docs/developers/routing-and-previews.md` | public routes, previews, root-level slugs |
| `docs/developers/search.md` | plain-text projection and indexing |

The doc is the authority — if a check below disagrees with the current doc,
follow the doc and note the discrepancy in your report.

Optional Koi context: when auditing a Koi app, a koi checkout (`../koi` or
`../katalyst-koi` beside the audited project) provides
`docs/skills/content-admin.md`, which records request-spec style
conventions (e.g. combined redirect assertions); use it when reviewing test
coverage.

## 3. Gather evidence

Prefer executable evidence over grep when it is cheap:

- `bin/rails routes -g <model>` — proves which route helpers exist,
  including routes produced by constraints and `resolve`.
- `db/schema.rb` (or structure.sql) — actual schema, not migration intent.
- The model, its `Version`, the public controller and views, `config/routes.rb`.
- `spec/` — request specs for the public controller, model specs, factories.

Never modify the audited project. If you need runtime evidence
(`bin/rails runner`), keep it read-only.

## 4. Checks

For each check record: pass / fail / not applicable, evidence (`file:line`
or command output), and the doc that defines it.

### Model and schema (getting-started, containers)

- Model includes `Katalyst::Content::Container`; a nested `Version` model
  includes `Katalyst::Content::Version`.
- Schema has a `<model>_versions` table with a non-null `parent` reference
  and `nodes` json column, and the model's table has `published_version` and
  `draft_version` references.
- Model defines a meaningful `to_s`.
- If the module is routed by slug: slug presence and uniqueness are
  validated, and the column has a unique database index.

### Frontend routing and previews (routing-and-previews)

- Public `show` route and `preview` member route exist and appear in
  `bin/rails routes -g <model>`. The editor's status bar depends on
  `url_for(container)` resolving; missing routes crash the admin editor.
- **Resolver**: when the module is slug-routed, `resolve("<Model>")` is
  declared so `url_for` generates slug URLs rather than `/plural/:id`.
- `show` returns 404 (`ActiveRecord::RecordNotFound`) for unpublished
  records and renders the published version via `render_content`.
- `preview` renders the draft version, redirects to `show` when the record's
  state is `published`, and is restricted to signed-in admins **in the
  controller** — raising `RecordNotFound` (a 404, so drafts don't reveal
  their existence), not redirecting.
- If root-level slugs are used: the constraint decides routing only (no
  authorisation inside it), explicit static routes sit above the constraint
  block, the constraint is limited to `format: :html`, and only one module
  claims root slugs.
- The controller/view uses `render_content` with `FrontendHelper`, not
  manual iteration of `version.items`.

### Search (search)

Applicable when the application has a search integration (pg_search or
similar). If it has none, record the section as not applicable.

- The module indexes `published_text`, so search reflects what visitors see.
- Indexing is gated with `if: :published?`.
- Re-indexing triggers on `saved_change_to_attribute?(:published_version_id)`
  (plus any other indexed attributes) — `published_text` is computed, so the
  search library cannot detect changes itself.

### Test coverage

Specs should test the module, not the gem. Gem behaviour — copy-on-write
versioning, state transitions, editor internals, attachment duplication —
has its own coverage; re-testing it adds cost without confidence.

Module behaviour worth covering:

- `GET show` for a published record renders published content.
- `GET show` for an unpublished record returns 404.
- `GET preview` as an admin renders the draft.
- `GET preview` unauthenticated returns 404.
- With root-level slugs: unknown slugs fall through to 404.
- If search applies: publishing updates the search index.

Also check factories follow the container pattern from getting-started
(items assigned to the container, `items_attributes` + `publish!` for
published factories).

## 5. Report

Deliver a report, most severe first — make no code changes:

1. **Critical** — security or data exposure: preview reachable without
   authentication; unpublished content publicly routable; slug routing
   without a unique index.
2. **Broken** — errors waiting to happen: missing show/preview routes;
   missing `resolve` on a slug-routed module (wrong URLs from `url_for`).
3. **Drift** — divergence from documented conventions: redirect where a 404
   is documented, authorisation inside a routing constraint, manual item
   iteration.
4. **Advisory** — search gaps, missing `to_s`, missing spec coverage.

Each finding: one-sentence defect, evidence (`file:line`), and the doc
reference. Close with two explicit lists: checks that passed, and checks
that were skipped or not applicable (and why) — a clean report must not
imply coverage it didn't have.
