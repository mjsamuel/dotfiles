---
name: htmldoc
description: Use when the user asks for a HTML doc/writeup.
---

Write a plain, self-contained HTML page.

## Procedure

1. Copy `<skill-dir>/template.html` to `~/.cache/htmldoc/<repo>-<kebab-topic>-<YYYY-MM-DD>.html`.
2. Replace `TITLE` and `CONTEXT`, and put the content where `<!-- content -->` is.
3. Do not open the result. End with the path, on its own line.

## Rules

- Lead with the conclusion. Keep it concise and human readable. 
- Don't use jargon and speak coherently. State things simply and concisely, like one human talking to another.
- Use fewer words and more pictures/diagrams.
- For diagrams, write Mermaid source in `<pre class="mermaid">`. Prefer top-to-bottom layouts.

## Classes

Only these exist:

- `note`: grey, smaller text for context, such as branch, paths, or caveats under a heading.
- `goal`: blue box for the outcome of a section ("Result: …").
- `warn`: amber box for risks and caveats.
- `checklist` on a `<ul>`: task list. Each item is
  `<li><label><input type="checkbox">Task</label><span class="why">Why or how.</span></li>`.
  Add `checked` for done items.
- `why`: an indented grey explanation under a list item.
- `mermaid` on a `<pre>`: a diagram.
- `add` / `del`: wrap diff lines in `<pre>`, e.g. `<span class="add">+ new line</span>`.
