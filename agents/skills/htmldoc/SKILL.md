---
name: htmldoc
description: Render a document as a self-contained HTML page. Use only when the user explicitly asks for a HTML document/writeup (e.g. "present this as html"). Do not use for ordinary text responses.
---

Write a semantic fragment, then render it. **Do not read `template.html`**: the renderer wraps your fragment in it.

## Procedure

1. Write the fragment to a temporary file.
2. Render it, then remove the fragment:
   ```bash
   python3 <skill-dir>/render.py <fragment> --type Plan --slug <kebab-topic> --model <model> && rm <fragment>
   ```
   Repo, branch, date, title, and output path are derived. `--type` is normally Plan, Research, or Walkthrough.
3. **Do not open the result.** End with the path it printed, on its own line.

## Rules

- Write code, diffs, and Mermaid literally — the renderer escapes and dedents them. Escape `&` and `<` in ordinary prose.
- No `<html>`, `<head>`, `<body>`, `<style>`, `<script>`, `<link>`, inline styles, or invented classes. The renderer rejects them with a line number.
- Replace every placeholder; keep prose concise and lead with conclusions.

## Skeleton

```html
<doc>
  <h1>HEADING</h1>
  <standfirst>SUMMARY</standfirst>
  <tldr><h2>CONCLUSION</h2><p>ANSWER</p></tldr>
  <sec title="TITLE">…</sec>
</doc>
```

An `<em>` may accent one phrase in `<h1>`. Include the `<tldr>`; omit it only for purely descriptive reference.

Everything inside `<doc>` is freeform — add, remove, reorder, or omit to fit the document. It is an injection boundary, not a fixed schema. Ordinary HTML (`<p>`, lists, `<table>`, `<h3>`, `<a>`, `<code>`, `<details>`) passes through, as does anything using the shell's own classes. The tags below are shorthand for the common shapes; nest them freely.

## Elements

- `<sec title="T">` — section. Id, number, and a contents row (at 4+ sections) are added for you; override with `<doc numbering="off">`, `<doc toc="off|on">`, or a `<toc/>` marker placing the row.
- `<callout label="L" [warn]>` — aside; `warn` for risks and caveats.
- `<cols [n="3"]>` — 2- or 3-up row, short sibling blocks only.
- `<codeblock [lang="ts"] [loc="src/a.ts"]>` — omit `lang` for logs and command output.
- `<mermaid [caption="C"]>` — source only, rendered live. Prefer a diagram when relationships or flow read better than prose.
- `<diff file="P" kind="proposed|actual" [closed]>` — paste a unified diff; lines are classified. Always label which kind.
- `<stepper>` with `<step title="T" [loc="P"]>` — a sequence. Inside a step, `<in>`/`<out>` show its I/O; add `closed` to collapse.

Prefer steppers for sequences, tables for comparisons and risks, diffs for code changes. `sample.html` is a worked example using every element.
