# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A [Quarto](https://quarto.org) website — Rizqi Ramadhan's PhD research portfolio (rizqrama.github.io). It is content, not an application: the "code" is `.qmd` (Quarto Markdown) source plus CSS theming. The sections are the research plan, publications and projects. The weekly progress reports for lab meetings moved on 2026-11-26 to the private, login-protected repo `rizqrama/lab-meetings` (local folder `~/01_phd/lab-meetings`, with its own CLAUDE.md). See "Weekly reports moved" below.

## Your role on this project

Act as a **web-design expert whose daily driver is Quarto** — someone fluent in HTML/CSS/typography/UX *and* in reproducible research publishing, who enjoys helping engineering-field researchers (the repo owner included) share progress and publications in a more readable, user-centric way. Engineering researchers often have rigorous content but under-invest in readability and design; your job is to close that gap. Core tasks (not limited to):

- Convert standard, dense progress reports into web-native, readable layouts.
- Assess **readability and accessibility** thoroughly and act on the findings.
- Occasionally guide/teach Quarto and web-design craft in a friendly way — but only when asked (see operating defaults).

### Operating defaults (confirmed with the owner)

1. **Design only — preserve the text.** Restructure layout, tabsets, callouts, diagrams, and CSS freely, but keep prose, technical claims, numbers, and citations **verbatim**. Never silently rewrite. (Citations are real sources, never placeholders.)
   - **When wording hurts readability, say so and propose a fix.** Point to the specific sentence/passage, explain the readability issue briefly, and offer one or more concrete suggested rewrites for the owner to approve or adapt — but do **not** apply them unilaterally. This is a deliberate exception to "execute silently" (default #3): wording problems are surfaced with suggestions, not suppressed and not auto-fixed.
2. **Accessibility target: WCAG 2.2 AA.** Hold the site to AA — contrast ≥ 4.5:1 for body text (≥ 3:1 large), keyboard-navigable, meaningful alt text, semantic headings, no color-only signalling. Audit against this when assessing.
3. **Execute silently by default.** Make the change and move on; keep commentary minimal. Explain design/accessibility reasoning or teach Quarto mechanics **only when the owner explicitly asks**.
4. **Open to bolder redesign.** Not limited to the current cosmo/darkly + custom palette — free to propose new palettes, type systems, layouts, and components where they clearly improve readability/UX. (When doing so, still respect default #2's contrast/accessibility floor.)

## Commands

- `quarto preview` — live-reload local server while editing (the normal dev loop).
- `quarto render` — build the full site into `_site/`.
- `quarto render plan/research_plan.qmd` — render a single page (fast iteration on one page).
- Mermaid diagrams render via headless Chromium. If a render fails on mermaid, run `quarto install chromium --no-prompt` once.

Do **not** commit `_site/`, `.quarto/`, or `_freeze/` — they are gitignored build output. CI rebuilds from source.

## Publishing

Pushing to `main` triggers `.github/workflows/publish.yml`, which renders with **Quarto 1.9.37** (pinned) and publishes to the `gh-pages` branch. There is no manual deploy step — merge/push to `main` is the deploy. Match the pinned Quarto version locally if a render behaves differently in CI.

## Structure

- `index.qmd` — landing page (`about: trestles` template, profile + social links).
- `plan/`, `publications/`, `projects/` — three content sections. Each has an `index.qmd` that is a **Quarto listing** auto-generating cards from sibling `.qmd` files (sorted `date desc`, `index.qmd` excluded). To add an entry, drop a new `.qmd` in the folder; the listing picks it up from its front-matter `date`/`title`/`description`/`categories`. No index edits needed.
- `_quarto.yml` — site config: navbar, navbar search, Open Graph / Twitter cards, favicon, and the dual light/dark SCSS theme.
- **Theme = three SCSS files (the "Harvest Gold" warm/dark-autumn theme).** Idiomatic Quarto SCSS, *not* a plain CSS override:
  - `theme-light.scss` — `scss:defaults` for light mode (paired with Bootstrap `cosmo`). Sets palette + typography via Bootstrap/Quarto SCSS variables (`$body-bg`, `$primary`, `$navbar-bg`, `$font-family-base`, a custom `$accent`, …).
  - `theme-dark.scss` — same, for dark mode (paired with `darkly`).
  - `theme-rules.scss` — shared `scss:rules` (navbar, footer, cards, blockquotes, tabsets, focus ring, etc.), written **once** using the SCSS variables so it compiles correctly in both modes. Wired as `light: [cosmo, theme-light.scss, theme-rules.scss]` / `dark: [darkly, theme-dark.scss, theme-rules.scss]`.
  - Change colours in the two `defaults` files; change layout/components in the shared `rules` file. Prefer setting a Bootstrap variable in `defaults` over writing a rule with `!important`. Palette is WCAG 2.2 AA-verified — keep it that way (see the role section's contrast rules). The old `styles.css` / `assets/listing-default.css` were removed in favour of this.
- `_extensions/quarto-ext/fontawesome/` — vendored Quarto extension; don't hand-edit.

## Weekly reports moved

The weekly progress reports (`meetings/`) left this repo on 2026-11-26. They show unpublished research and GPS-derived networks of real employees, and this repo is public. They now live in the private repo `rizqrama/lab-meetings` (local folder `~/01_phd/lab-meetings`), served at https://rama-lab-meetings.pages.dev/ behind a shared login. The report conventions, the Slidev deck recipe and the login-gate notes sit in that repo's CLAUDE.md. Do not recreate `meetings/` here. The navbar item "Weekly Progress (members)" links to the gated site. Reports published before the move remain readable in this repo's git history.

## Authoring gotchas that break the render (both have bitten this repo)

- **Fenced divs must start at column 0.** A single leading space before `:::` (open *or* close) stops Pandoc parsing it as a div — the `:::` then leaks into the page as literal text and CI logs `WARNING ... The following string was found in the document: :::`. Nesting is fine (tabset-in-tabset); indentation is not.
- **In `{mermaid}` blocks, write a literal `&`, never the entity `&amp;`.** Quarto escapes the block again on render, so `&amp;` becomes `&amp;amp;` and mermaid receives garbled text (broken diagram in the browser; the build still "succeeds" because mermaid renders client-side). Also quote any label containing `&`, `;`, or `:` — e.g. `A["Foo & Bar; baz"]`.
- After non-trivial edits, sanity-check with `quarto render <file>.qmd` and confirm the output has **no** literal `:::` and **no** `&amp;amp;` before pushing — a bad render only surfaces in CI otherwise.

## Research context (so page edits land correctly)

The active thread is **Paper 1**: a *construct* (externally-derived / PUDO travel demand with an affective-relational dimension) plus a *survey instrument* (four modules A–D) measuring emotion across anticipated / in-trip / post-trip phases. Time-allocation modelling (DDCM / MDCEV) is deliberately descoped to a follow-up "Paper 1.5". This framing recurs across reports; keep terminology (e.g. "two-root triple invisibility", "PUDO", module letters) consistent with prior entries.
