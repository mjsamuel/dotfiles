---
name: htmldoc
description: Render a document as a self-contained HTML page. Use only when the user explicitly asks for a HTML document/writeup (e.g. "present this as html"). Do not use for ordinary text responses.
---

Render the document as HTML based on `template.html` in this skill's directory.

## Procedure

1. Read `template.html` in full.
2. Compute the output path:
   ```bash
   repo=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
   mkdir -p ~/.cache/htmldoc
   # ~/.cache/htmldoc/<repo>-<slug>-<YYYY-MM-DD>.html   (slug: short kebab-case topic)
   ```
3. Write the document. **Do not open it.** End your response with the absolute file path on its own line so it can be copied into a browser.

## Hard rules

- **Never modify** the `<style>` block, the `<script>` blocks, or the `<link>`/CDN tags. Copy them byte-for-byte.
- **Always HTML-escape** code and diff content (`<` → `&lt;`, `&` → `&amp;`).
- Use only the components below. No new classes, no inline styles.
- The template's example content is placeholder — replace all of it.

## Structure

**Mandatory frame** (keeps provenance consistent):
- `header.topbar` — repo/project name + date
- `.doc-head` — doc-type pill (e.g. `Plan`, `Research`, `Walkthrough`), `<h1>` (may use one `<em>` for an accented word), `.standfirst` (1–2 sentences)
- `footer.foot` — repo @ branch, model

**Everything in between is freeform** — structure the document however best serves the content. Defaults, not rules:

- `section.tldr` — **include by default**; omit only for purely descriptive reference material. Lead with the conclusion/answer.
- `.toc-row` with `nav.toc` pills — when the doc is long (4+ sections). Always keep the `.ctl-row` expand/collapse buttons if the doc contains `<details>`.
- `section.sec` with `.sec-num` + `<h2>` — number sections when there's a reading order; skip numbering when there isn't.

## Components (live examples of each are in the template)

- **Prose**: `<p>`, `<ul>`/`<ol>`, `<table>` (comparisons, risks), inline `<code>`.
- **Callout**: `<aside class="callout">` (or `callout warn`) with `<span class="label">Note</span>` + `<p>`.
- **Columns**: wrap sibling blocks in `<div class="cols">` (or `cols cols-3`) to place them side by side — paired callouts, input/output, code + notes. Never long prose.
- **Code block**: `<figure class="codeblock">` with optional `<figcaption><span class="pill pill-loc">path/file.ts</span></figcaption>` and `<pre class="code"><code class="language-ts">…</code></pre>`.
- **Stepper** (walkthroughs, call stacks, sequences): `<ol class="stepper">` of `<li class="step">`, each with `.step-head` (`<h3>` + `<span class="pill pill-loc">file.ts:42</span>`), one short `<p>`, and optional I/O blocks: `<details class="io io-in">`/`<details class="io io-out">` with `<summary>Input</summary>` + a `pre.code`. Add `open` to short/important blocks; leave long ones collapsed. A step's output may be a diff — embed it directly.
- **Diff** (unified only): `<details class="diff" open>` with `<summary><span class="diff-file">path</span><span class="pill pill-proposed">proposed</span></summary>` (`pill-actual`/`actual` for real diffs from git — **always label which**), then `.diff-body` of `.dline` rows: `hunk`, `ctx`, `del`, `add`. Keep leading `+`/`-`/space. Collapse long or secondary diffs.

## Code highlighting

highlight.js runs from CDN — write **plain escaped code**, never manual token spans. Add `class="language-x"` on the `<code>` element to opt in (`language-typescript`, `language-python`, `language-bash`, `language-json`, …). Omit the class for output dumps, logs, or anything that isn't real code.

## Writing style

- Lead with conclusions; a TL;DR must stand alone.
- Tight sections — this is a document to scan, not a transcript.
- Prefer a stepper for anything sequential, a table for anything comparative, a diff for anything that changes code.
