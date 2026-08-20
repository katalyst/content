---
name: content-audit
description: Audit an entire Rails application's Katalyst Content integration - gem setup, then every container model and custom item type. Use when asked to audit, lint, or review the app's content setup or all of its content modules. For a single named module or item, use content-module-audit or content-item-audit instead. Reports findings; does not change code.
---

# Content Audit

Audit a whole application's Katalyst Content integration: verify the
project-level gem setup, inventory every container and custom item, then
apply the focused sibling skills to each target and aggregate the results.

If the user's ask is actually about one specific module or item, offer to
narrow to `content-module-audit` or `content-item-audit` instead — this
skill is for the app-wide pass. Report-only: never modify the audited
project, and keep any runtime evidence read-only.

## 1. Establish context: read the docs first

Follow the docs protocol from `../content-module-audit/SKILL.md` step 2:
the docs ship in this skill's own repository — resolve the skill's real
location and read them from there, verifying the repository is on `main`
and current (ask before any state-changing git command). Establish this
once — the focused skills reuse it.

Read for the setup checks (the focused skills read their own docs):

| Doc | Establishes |
| --- | --- |
| `docs/developers/getting-started.md` | installation, assets, migrations |
| `docs/developers/configuration.md` | config options, `base_controller` security |
| `docs/developers/items/themes.md` | theme registration and CSS |
| `docs/developers/performance.md` | fragment caching requirements |

The doc is the authority — if a check below disagrees with the current doc,
follow the doc and note the discrepancy in your report.

## 2. Setup checks

For each check record: pass / fail / not applicable, evidence (`file:line`
or command output), and the doc that defines it.

- **Versions** — `Gemfile.lock`: katalyst-content is v3 (this skill and its
  siblings audit the v3 contract; report and stop on older majors). Note
  whether koi is present — Koi wires several of the checks below
  automatically.
- **Engine mounted** — non-Koi apps mount `Katalyst::Content::Engine`
  themselves; Koi mounts it at `/admin/content`. Flag double-mounts.
- **Migrations installed** — `katalyst_content_items` exists in
  `db/schema.rb`.
- **`base_controller` is an authenticated admin base** — the one
  security-critical check: the engine's item endpoints inherit from it, and
  the default (`ApplicationController`) leaves item editing only as
  protected as the public site. Koi sets `Admin::ApplicationController`;
  check the initializer for unsafe overrides, and in non-Koi apps require an
  explicit setting.
- **Assets** — the frontend stylesheet is imported in the application
  bundle; in non-Koi apps, also the editor stylesheet and the
  `@katalyst/content` JavaScript (Koi loads editor assets automatically).
- **Themes** — every name in `config.themes` has a
  `[data-content-theme="…"]` CSS block in the project's stylesheets. The gem
  ships minimal defaults for `light`/`dark` (missing project CSS for those
  is advisory); a custom theme with no CSS block renders unstyled.
- **Cache store** — production configures a real cache store;
  `render_content` fragment caching is load-bearing for frontend
  performance.

## 3. Inventory

- **Containers**: `grep -rln "include Katalyst::Content::Container" app/models`
- **Custom items**: `Katalyst::Content.config.items` minus the
  `Katalyst::Content::*` built-ins, cross-checked against
  `grep -rln "< Katalyst::Content::Item" app/models`

Flag discrepancies the focused skills cannot see:

- A registered class name that does not resolve to a class on disk (editor
  crash).
- An `Item` subclass on disk that is not registered (invisible to editors —
  possibly intentional, so report as advisory).

Present the inventory and expected effort (one focused audit per target)
and confirm scope with the user before fanning out — they may want to limit
a large app to specific targets.

## 4. Audit each target

Apply the sibling skills, passing along the docs checkout location so each
run skips rediscovery:

- Each container: follow `../content-module-audit/SKILL.md`.
- Each custom item: follow `../content-item-audit/SKILL.md`.

Targets are independent — where your environment supports parallel
subagents, audit targets concurrently (one target per agent, each returning
its findings); otherwise work through them sequentially. Either way, every
target gets the full focused checklist — do not sample.

## 5. Aggregate report

Deliver a single report — make no code changes:

1. **Setup findings** first, ranked by the severity tiers the focused
   skills use (critical / broken / drift / advisory). `base_controller`
   failures are critical.
2. **Per-target rollups**: one section per container and item, findings
   ranked most-severe first with `file:line` evidence and doc references.
3. **Deduplicate patterns**: a defect repeated across targets (e.g. every
   module missing its resolver) becomes one finding listing its instances,
   not N copies.
4. Close with combined lists of checks that passed and checks that were
   skipped or not applicable (and why) — including any targets the user
   excluded in step 3, so the report never implies coverage it didn't have.
