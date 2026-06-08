# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A [Quarto](https://quarto.org) website — Rizqi Ramadhan's PhD research portfolio (rizqrama.github.io). It is content, not an application: the "code" is `.qmd` (Quarto Markdown) source plus CSS theming. The main deliverables are **weekly progress reports** under `meetings/`, archived for lab meetings with Chikaraishi Sensei at Hiroshima University's Urban and Transportation Planning Lab.

## Commands

- `quarto preview` — live-reload local server while editing (the normal dev loop).
- `quarto render` — build the full site into `_site/`.
- `quarto render meetings/20260608.qmd` — render a single page (fast iteration on one report).
- Mermaid diagrams render via headless Chromium. If a render fails on mermaid, run `quarto install chromium --no-prompt` once.

Do **not** commit `_site/`, `.quarto/`, or `_freeze/` — they are gitignored build output. CI rebuilds from source.

## Publishing

Pushing to `main` triggers `.github/workflows/publish.yml`, which renders with **Quarto 1.9.37** (pinned) and publishes to the `gh-pages` branch. There is no manual deploy step — merge/push to `main` is the deploy. Match the pinned Quarto version locally if a render behaves differently in CI.

## Structure

- `index.qmd` — landing page (`about: trestles` template, profile + social links).
- `meetings/`, `publications/`, `projects/` — three content sections. Each has an `index.qmd` that is a **Quarto listing** auto-generating cards from sibling `.qmd` files (sorted `date desc`, `index.qmd` excluded). To add an entry, drop a new `.qmd` in the folder; the listing picks it up from its front-matter `date`/`title`/`description`/`categories`. No index edits needed.
- `_quarto.yml` — site config: navbar, global HTML format (cosmo light / darkly dark themes), `styles.css`.
- `styles.css` — site-wide theme. Custom palette defined as CSS variables in `:root` (alabaster-grey, soft-linen, tuscan-sun, carbon-black, graphite); Georgia serif body, Helvetica nav. Light + dark mode rules.
- `assets/listing-default.css` — styling specific to the listing index pages, linked per-page via `header-includes` (not global).
- `_extensions/quarto-ext/fontawesome/` — vendored Quarto extension; don't hand-edit.

Meeting reports are named by date: `meetings/YYYYMMDD.qmd`.

## Report conventions (meetings/)

Progress reports follow a deliberate, consistent structure — when creating or editing one, mirror the most recent report (e.g. `meetings/20260608.qmd`):

- **Dual-view tabsets.** Most sections wrap content in `::: {.panel-tabset}` with a **Presentation** tab (slide-style action-title headings, summary tables, mermaid diagrams) and a **Detailed** tab (prose with *Current thought / Reasoning / Alternatives considered* paragraphs). Same logical flow, two zoom levels.
- **Action-title headings** — section headings state the takeaway as a full sentence, not a topic label.
- **Self-contained HTML** — reports set `embed-resources: true` in their own front matter so each page is one shareable file. Per-report front matter also commonly overrides `toc-location: left`, `toc-depth`, `theme: cosmo`, and sets `mermaid: theme: default`.
- **Mermaid diagrams** use a recurring custom color scheme (dark green `#1f2d2a`/`#3a5a4a` for concepts, brown `#4a3a2a` for outputs) via `classDef`. Reuse those classes for visual consistency across reports.
- Reports cite a large literature with short citation keys (e.g. `Souche-Le Corvec & Zhao 2020`) and a source-code map table in the appendix. When editing report content, preserve citation accuracy — these are real academic sources, not placeholders.

## Research context (so report edits land correctly)

The active thread is **Paper 1**: a *construct* (externally-derived / PUDO travel demand with an affective-relational dimension) plus a *survey instrument* (four modules A–D) measuring emotion across anticipated / in-trip / post-trip phases. Time-allocation modelling (DDCM / MDCEV) is deliberately descoped to a follow-up "Paper 1.5". This framing recurs across reports; keep terminology (e.g. "two-root triple invisibility", "PUDO", module letters) consistent with prior entries.
