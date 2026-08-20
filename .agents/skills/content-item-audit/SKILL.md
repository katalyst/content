---
name: content-item-audit
description: Audit a single custom Katalyst Content item type (a subclass of Katalyst::Content::Item) against documented best practices. Use when asked to audit, lint, or review a custom content item or block (e.g. Content::Spacer, Content::DonationForm) in a Rails app. Checks registration, params, data modelling, duplication safety, partials, search, and test coverage. Reports findings; does not change code.
---

# Content Item Audit

Lint one custom content item type — an application-defined subclass of
`Katalyst::Content::Item` — against the documented best practices. Like a
context-aware rubocop: it checks behaviour and wiring, not style, and it
reports rather than fixes.

The gem's built-in items (Section, Group, Column, Aside, Content, Figure,
Table) are out of scope — if asked to audit one, say so and stop. Container
models and app-wide gem configuration are covered by the sibling
`content-module-audit` and `content-audit` skills. One item type per run.

## 1. Select the item

If the user named a class, use it. Otherwise find candidates:

- Read `Katalyst::Content.config.items` from
  `config/initializers/katalyst_content.rb` and drop the
  `Katalyst::Content::*` built-ins.
- Also grep `app/models` for subclasses:
  `grep -rln "< Katalyst::Content::Item" app/models`

If there are multiple candidates, ask the user which to audit. If a subclass
exists on disk but is not registered in `config.items`, that is itself a
finding (the editor cannot offer it).

## 2. Establish context: read the docs first

Follow the docs protocol from `../content-module-audit/SKILL.md` step 2:
the docs ship in this skill's own repository — resolve the skill's real
location and read them from there, verifying the repository is on `main`
and current (ask before any state-changing git command). If the docs have
already been located this session (e.g. by `content-audit`), reuse them.

Read before auditing (paths relative to the repository root):

| Doc | Establishes |
| --- | --- |
| `docs/developers/items/index.md` | item anatomy, shared attributes, rendering |
| `docs/developers/items/custom-items.md` | modelling, duplication, testing |
| `docs/developers/search.md` | `to_plain_text` expectations |
| `docs/developers/configuration.md` | image validation conventions only |

The doc is the authority — if a check below disagrees with the current doc,
follow the doc and note the discrepancy in your report.

## 3. Gather evidence

- The item class and any detail model it owns.
- `config/initializers/katalyst_content.rb` — registration.
- The item's partials, resolved from the model's partial path — for
  `Content::Spacer`: `app/views/content/spacers/_spacer.html.erb` (frontend)
  and `_spacer.html+form.erb` (editor form).
- `bundle exec rubocop --only Koi/DuplicatesAssociation <files>` when
  rubocop-katalyst is in the bundle — prefer running the cop over
  reimplementing its analysis.
- `spec/models/**` for the item's specs and factories.

Never modify the audited project; keep any runtime evidence read-only.

## 4. Checks

For each check record: pass / fail / not applicable, evidence (`file:line`
or command output), and the doc that defines it.

### Registration and params (custom-items)

- The class is listed in `Katalyst::Content.config.items`.
- `permitted_params` is extended with every editor-editable attribute,
  including nested detail params — a missing entry silently drops editor
  input on save.

### Data modelling (custom-items)

- Type-specific presentation settings use `style_attributes`, not new
  columns on the shared table.
- Structured data (typed columns, foreign keys, own validations) lives in a
  detail table accessed via `has_one` with nested attributes — not crammed
  into the `style` JSON.
- Media items validate attachments against the configured conventions
  (`config.image_mime_types`, `config.max_image_size`) and add
  `default_scope { with_attached_* }`.

### Duplication safety (custom-items) — the highest-value check

Copy-on-write editing duplicates items with `dup`; the gem copies
attachments, rich text, and declared associations automatically. Anything
else is silently lost on the editor's next change.

- Every owned association (`dependent: :destroy` plus autosave or nested
  attributes) declares `duplicates_association`. Run the
  `Koi/DuplicatesAssociation` cop when available; inspect manually
  otherwise.
- No `initialize_dup` for state the gem already copies.
- No use of `clone` — only `dup` is supported.

### Partials and rendering (items, custom-items)

- Both partials exist: frontend (`_type.html.erb`) and editor form
  (`_type.html+form.erb`).
- The frontend partial wraps its output in `content_item_tag` so theme and
  visibility apply.
- The form partial uses the shared field helpers
  (`content_heading_fieldset`, `content_theme_field`, `govuk_*` fields for
  custom attributes).

### Search (search)

- If the item carries searchable content, it implements `to_plain_text`,
  returns `nil` when it should not contribute, and respects `visible?`.
- `to_plain_text` performs no queries beyond the item's own associations —
  it runs for every item when a container is indexed.

### Test coverage — test the item, not the gem

Attachment and rich-text duplication are gem features with their own
coverage; do not re-test them. Item behaviour worth covering:

- An integration-level `#dup` spec for each detail record the item owns.
- A whole-of-dup test: duplicate a fully populated item and save the copy —
  a broken dup silently loses content on the user's next edit.
- Validations for the item's own attributes.

## 5. Report

Deliver a report, most severe first — make no code changes:

1. **Critical** — silent data loss: owned association without
   `duplicates_association`.
2. **Broken** — errors or lost input: not registered in `config.items`,
   missing partials, editable attributes missing from `permitted_params`.
3. **Drift** — divergence from documented conventions: columns where
   `style_attributes` or a detail table is documented, missing
   `content_item_tag`, ad-hoc attachment validations.
4. **Advisory** — missing `to_plain_text`, missing dup specs, missing
   `with_attached_*` scope.

Each finding: one-sentence defect, evidence (`file:line`), and the doc
reference. Close with explicit lists of checks that passed and checks that
were skipped or not applicable (and why).
