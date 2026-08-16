---
name: htmldoc
description: Render a document as a self-contained HTML page. Use only when the user explicitly asks for a HTML document/writeup (e.g. "present this as html"). Do not use for ordinary text responses.
---

Render with this skill's `render.py`. **Do not read `template.html`**: it is an opaque shell that the renderer adds around your content.

## Procedure

1. Determine repo, branch, date, model, and a short kebab-case topic slug.
2. Write a temporary HTML fragment containing the mandatory frame below and the document content.
3. Render and remove the fragment:
   ```bash
   repo=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
   out="$HOME/.cache/htmldoc/${repo}-<slug>-$(date +%F).html"
   mkdir -p "$(dirname "$out")"
   python3 <skill-dir>/render.py <fragment> "$out" && rm <fragment>
   ```
4. **Do not open the result.** End with its absolute path on its own line.

## Rules

- Write content only: no `<html>`, `<head>`, `<body>`, `<style>`, `<script>`, `<link>`, new classes, or inline styles. Approved shell scripts such as Mermaid and Highlight.js are supplied by the template, never by fragments.
- The output is a single HTML page but may load approved libraries from a CDN when opened.
- HTML-escape code, diffs, and Mermaid labels containing HTML-significant characters (`&` first, then `<`: `&amp;`, `&lt;`).
- Replace all placeholders; keep prose concise and lead with conclusions.

## Mandatory frame

```html
<header class="topbar">
  <div class="brand">REPO<span> · htmldoc</span></div><div class="topbar-meta">YYYY-MM-DD</div>
</header>
<main>
  <div class="doc-head"><span class="pill pill-type">TYPE</span><h1>HEADING</h1><p class="standfirst">SUMMARY</p></div>
  DOCUMENT
</main>
<footer class="foot"><span><b>repo</b> REPO @ BRANCH</span><span><b>model</b> MODEL</span></footer>
```

`TYPE` is normally Plan, Research, or Walkthrough. An `<em>` may accent one phrase in `<h1>`.

## Structure

Everything between `.doc-head` and the footer is freeform: add, remove, reorder, or omit sections and components to fit the document. The fragment is an injection boundary, not a fixed schema.

- Default to `<section class="tldr"><span class="pill">TL;DR</span><h2>CONCLUSION</h2><p>ANSWER</p></section>`; omit only for purely descriptive reference.
- Use `<section class="sec" id="s01"><div class="sec-head"><span class="sec-num">01</span><h2>TITLE</h2></div>…</section>`. Number only when order matters.
- For 4+ sections add `.toc-row` containing `nav.toc` links (`a.pill`). If any `<details>` exist, also include `.ctl-row` with buttons `id="expand-all"` and `id="collapse-all"`.

## Components

- Prose: `<p>`, lists, `<table>`, inline `<code>`.
- Callout: `<aside class="callout">` (or `callout warn`) with `<span class="label">LABEL</span><p>…</p>`.
- Columns: `<div class="cols">` or `cols cols-3` around short sibling blocks only.
- Code: `<figure class="codeblock"><figcaption><span class="pill pill-loc">PATH</span></figcaption><pre class="code"><code class="language-LANG">ESCAPED CODE</code></pre></figure>`. Omit language for logs/output; never add token spans.
- Mermaid diagram: `<figure><figcaption>CAPTION</figcaption><pre class="mermaid">MERMAID SOURCE</pre></figure>`. Mermaid is rendered live by the shell; include source only, without initialization scripts. Prefer diagrams when relationships or flow are clearer visually than in prose.
- Sequence: `<ol class="stepper"><li class="step"><div class="step-head"><h3>TITLE</h3><span class="pill pill-loc">LOC</span></div><p>…</p></li></ol>`. Optional I/O: `<details class="io io-in|io-out" open><summary>Input|Output</summary><pre class="code"><code>…</code></pre></details>`; collapse long blocks.
- Unified diff: `<details class="diff" open><summary><span class="diff-file">PATH</span><span class="pill pill-proposed">proposed</span></summary><div class="diff-body"><div class="dline hunk|ctx|del|add">LINE</div></div></details>`. Use `pill-actual`/`actual` for git diffs; always label which. Preserve leading `+`, `-`, or space; collapse long/secondary diffs.

Prefer steppers for sequences, tables for comparisons/risks, and diffs for code changes.
