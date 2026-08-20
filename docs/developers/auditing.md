---
layout: default
title: Auditing
parent: Developers
nav_order: 8
---

# Auditing

This repository ships agent skills that audit an application's content
integration against this documentation — context-aware linters that check
behaviour and wiring rather than style, report findings with file and line
evidence, and never change code.

* **content-audit** — the app-wide pass: verifies gem setup (mounting,
  migrations, `base_controller` security, assets, themes, cache store),
  inventories the app's containers and custom items, and applies the
  focused skills below to each.
* **content-module-audit** — one container model: schema and model setup,
  frontend routing and previews, search integration, and test coverage.
* **content-item-audit** — one custom item type: registration, permitted
  params, data modelling, duplication safety, partials, search, and test
  coverage.

## Installation

The skills live in [`.agents/skills/`](https://github.com/katalyst/content/tree/main/.agents/skills).
Clone this repository, then symlink them into your agent's skills
directory — all three together, since `content-audit` references its
siblings by relative path:

```shell
# from the root of your katalyst/content clone
for skill in content-audit content-module-audit content-item-audit; do
  ln -s "$PWD/.agents/skills/$skill" ~/.claude/skills/$skill
done
```

Keep the clone up to date — the skills read this documentation from the
repository they ship in, so a current checkout means a current audit.

## Usage

Ask your agent to audit content, scoped to what you care about: the whole
application ("audit this app's content setup"), one container ("audit the
Page content module"), or one item type ("audit Content::Spacer"). Findings
come back ranked by severity, each with evidence and a reference to the
page of this documentation that defines the expectation.
