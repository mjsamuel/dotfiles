#!/usr/bin/env python3
"""Expand an htmldoc fragment into the static self-contained shell.

The fragment is semantic: the model writes what a block *is*, this renders how
it looks. Chrome (top bar, doc head, footer, contents row) is generated here so
it never has to be retyped, and literal blocks (code, diffs, mermaid) are
escaped and dedented here so they can be written verbatim.
"""

from datetime import date
from html import escape
from pathlib import Path
import argparse
import re
import subprocess
import sys

CONTENT_MARKER = "<!-- HTMLDOC_CONTENT -->"
TITLE_MARKER = "<!-- HTMLDOC_TITLE -->"
FORBIDDEN = re.compile(r"<(?:/?(?:html|head|body)|/?(?:style|script)|link)\b", re.IGNORECASE)

# Tags whose contents are literal text: never parsed, always escaped and dedented.
LITERAL_TAGS = ("codeblock", "mermaid", "diff", "in", "out")
DSL_TAGS = {
    "doc", "standfirst", "tldr", "sec", "callout", "cols",
    "stepper", "step", "toc", "ctl", *LITERAL_TAGS,
}
HTML_TAGS = {
    "a", "abbr", "aside", "b", "blockquote", "br", "button", "caption", "cite",
    "code", "col", "colgroup", "dd", "del", "details", "div", "dl", "dt", "em",
    "figcaption", "figure", "h1", "h2", "h3", "h4", "h5", "h6", "header", "hr",
    "i", "img", "ins", "kbd", "li", "main", "mark", "nav", "ol", "p", "pre",
    "q", "s", "samp", "section", "small", "span", "strong", "sub", "summary",
    "sup", "table", "tbody", "td", "tfoot", "th", "thead", "time", "tr", "u",
    "ul", "var", "wbr", "footer",
}

TOC_SLOT = "\x01toc\x01"   # explicit <toc/>: place the row here, and want one
AUTO_SLOT = "\x01auto\x01"  # after a TL;DR: place the row here *if* there is one
CTL_SLOT = "\x01ctl\x01"
ATTR_RE = re.compile(r"""([\w-]+)(?:\s*=\s*(?:"([^"]*)"|'([^']*)'))?""")


class RenderError(Exception):
    def __init__(self, message, line=None, hint=None):
        super().__init__(message)
        self.line = line
        self.hint = hint


# ---------------------------------------------------------------- helpers


def parse_attrs(raw):
    """Attributes as a dict; bare attributes (`warn`, `closed`) map to ""."""
    return {name.lower(): dq or sq for name, dq, sq in ATTR_RE.findall(raw or "")}


def line_of(text, index):
    return text.count("\n", 0, index) + 1


def dedent(lines, indents):
    """Strip the common leading whitespace measured over `indents`."""
    widths = [len(line) - len(line.lstrip(" \t")) for line in indents if line.strip()]
    base = min(widths) if widths else 0
    return [line[base:] if line.strip() else "" for line in lines]


def literal_text(raw, diff=False):
    lines = raw.replace("\t", "    ").split("\n")
    while lines and not lines[0].strip():
        lines.pop(0)
    while lines and not lines[-1].strip():
        lines.pop()
    if not diff:
        return "\n".join(dedent(lines, lines))
    # Measure indentation from marker lines only, so a context line's leading
    # space (part of the diff format) survives.
    markers = [line for line in lines if line.lstrip().startswith(("@@", "+", "-"))]
    if markers:
        return "\n".join(dedent(lines, markers))
    widths = [len(line) - len(line.lstrip(" ")) for line in lines if line.strip()]
    base = max(0, (min(widths) if widths else 0) - 1)
    return "\n".join(line[base:] if line.strip() else "" for line in lines)


def allowed_classes(template):
    """Every class the shell's stylesheet actually styles, scraped at render time."""
    css = re.search(r"<style>(.*?)</style>", template, re.DOTALL)
    if not css:
        raise RenderError("template.html has no <style> block")
    return {name for name in re.findall(r"\.([a-zA-Z][\w-]*)", css.group(1))}


# ---------------------------------------------------------------- literals


def extract_literals(fragment):
    """Pull literal blocks out before anything parses the fragment as markup.

    Code and diffs routinely contain `<` and `&`; leaving them in place would
    mean the model has to escape them by hand. Placeholders keep the original
    line count so validation errors still point at the right line.
    """
    blocks = []

    def replace(match):
        tag = match.group(1).lower()
        attrs = parse_attrs(match.group(2))
        newlines = match.group(0).count("\n")
        blocks.append((render_literal(tag, attrs, match.group(3)), newlines))
        return f"\x00{len(blocks) - 1}\x00" + "\n" * newlines

    pattern = re.compile(
        r"<(" + "|".join(LITERAL_TAGS) + r")\b((?:\"[^\"]*\"|'[^']*'|[^>])*)>(.*?)</\1\s*>",
        re.DOTALL | re.IGNORECASE,
    )
    return pattern.sub(replace, fragment), blocks


def render_literal(tag, attrs, body):
    if tag == "diff":
        return render_diff(attrs, body)
    text = escape(literal_text(body), quote=False)
    if tag == "mermaid":
        caption = attrs.get("caption", "")
        head = f"\n      <figcaption>{caption}</figcaption>" if caption else ""
        return f'<figure>{head}\n      <pre class="mermaid">{text}</pre>\n    </figure>'
    if tag in ("in", "out"):
        label = "Input" if tag == "in" else "Output"
        state = "" if "closed" in attrs else " open"
        return (
            f'<details class="io io-{tag}"{state}>\n'
            f"          <summary>{label}</summary>\n"
            f'          <pre class="code"><code>{text}</code></pre>\n'
            f"        </details>"
        )
    lang = attrs.get("lang", "")
    loc = attrs.get("loc", "")
    head = f'\n      <figcaption><span class="pill pill-loc">{loc}</span></figcaption>' if loc else ""
    cls = f' class="language-{lang}"' if lang else ""
    line_count = text.count("\n") + 1
    pre = f'<pre class="code"><code{cls}>{text}</code></pre>'
    if line_count > 1:
        gutter = "\n".join(str(n) for n in range(1, line_count + 1))
        pre = (
            '<div class="code-frame">\n'
            f'        <pre class="code-gutter" aria-hidden="true">{gutter}</pre>\n'
            f"        {pre}\n"
            "      </div>"
        )
    return f'<figure class="codeblock">{head}\n' f"      {pre}\n" f"    </figure>"


def render_diff(attrs, body):
    kind = attrs.get("kind", "proposed").lower()
    if kind not in ("proposed", "actual"):
        raise RenderError(f'diff kind must be "proposed" or "actual", got "{kind}"')
    state = "" if "closed" in attrs else " open"
    rows = []
    for line in literal_text(body, diff=True).split("\n"):
        if line.startswith("@@"):
            cls = "hunk"
        elif line.startswith("+"):
            cls = "add"
        elif line.startswith("-"):
            cls = "del"
        else:
            cls = "ctx"
        rows.append(f'        <div class="dline {cls}">{escape(line, quote=False) or " "}</div>')
    body_html = "\n".join(rows)
    return (
        f'<details class="diff"{state}>\n'
        f'      <summary><span class="diff-file">{attrs.get("file", "")}</span>'
        f'<span class="pill pill-{kind}">{kind}</span></summary>\n'
        f'      <div class="diff-body">\n{body_html}\n      </div>\n'
        f"    </details>"
    )


# ---------------------------------------------------------------- validation


def validate(shell, classes):
    match = FORBIDDEN.search(shell)
    if match:
        raise RenderError(
            f'"{match.group(0)}>" is supplied by the shell, not by fragments',
            line_of(shell, match.start()),
        )

    for match in re.finditer(r'class\s*=\s*"([^"]*)"', shell):
        for name in match.group(1).split():
            if name in classes or name.startswith(("language-", "hljs")):
                continue
            raise RenderError(
                f'unknown class "{name}"',
                line_of(shell, match.start()),
                "the shell styles no such class — use one it defines, or a semantic tag",
            )

    for match in re.finditer(r"</?([a-zA-Z][\w-]*)", shell):
        name = match.group(1).lower()
        if name in HTML_TAGS or name in DSL_TAGS:
            continue
        raise RenderError(
            f"unknown tag <{name}>",
            line_of(shell, match.start()),
            "expected standard HTML or one of: " + ", ".join(sorted(DSL_TAGS)),
        )


# ---------------------------------------------------------------- expansion


def expand(shell, numbering):
    """Rewrite semantic tags into the shell's classes. Document order is kept."""
    sections = []

    def open_sec(match):
        attrs = parse_attrs(match.group(1))
        title = attrs.get("title", "")
        if not title:
            return '<section class="sec">'
        ident = attrs.get("id") or f"s{len(sections) + 1:02d}"
        sections.append((ident, title))
        num = ""
        if numbering and "nonum" not in attrs:
            num = f'<span class="sec-num">{len(sections):02d}</span>'
        return (
            f'<section class="sec" id="{ident}">\n'
            f'    <div class="sec-head">{num}<h2>{title}</h2></div>'
        )

    def open_callout(match):
        attrs = parse_attrs(match.group(1))
        warn = " warn" if "warn" in attrs else ""
        label = attrs.get("label", "")
        head = f'\n      <span class="label">{label}</span>' if label else ""
        return f'<aside class="callout{warn}">{head}'

    def open_cols(match):
        attrs = parse_attrs(match.group(1))
        return '<div class="cols cols-3">' if attrs.get("n") == "3" else '<div class="cols">'

    def open_step(match):
        attrs = parse_attrs(match.group(1))
        title = attrs.get("title", "")
        loc = attrs.get("loc", "")
        pill = f'<span class="pill pill-loc">{loc}</span>' if loc else ""
        if not title:
            return '<li class="step">'
        return f'<li class="step">\n        <div class="step-head"><h3>{title}</h3>{pill}</div>'

    rules = [
        (r"<sec\b((?:\"[^\"]*\"|'[^']*'|[^>])*)>", open_sec),
        (r"</sec\s*>", "</section>"),
        (
            r"<tldr\s*>",
            '<section class="tldr">\n    <span class="tldr-guy" aria-hidden="true"></span>'
            '\n    <span class="pill">TL;DR</span>',
        ),
        (r"</tldr\s*>", "</section>\n\n  " + AUTO_SLOT),
        (r"<callout\b((?:\"[^\"]*\"|'[^']*'|[^>])*)>", open_callout),
        (r"</callout\s*>", "</aside>"),
        (r"<cols\b((?:\"[^\"]*\"|'[^']*'|[^>])*)>", open_cols),
        (r"</cols\s*>", "</div>"),
        (r"<stepper\s*>", '<ol class="stepper">'),
        (r"</stepper\s*>", "</ol>"),
        (r"<step\b((?:\"[^\"]*\"|'[^']*'|[^>])*)>", open_step),
        (r"</step\s*>", "</li>"),
        (r"<toc\s*/?>", TOC_SLOT),
        (r"</toc\s*>", ""),
        (r"<ctl\s*/?>", CTL_SLOT),
        (r"</ctl\s*>", ""),
    ]
    for pattern, replacement in rules:
        if callable(replacement):
            shell = re.sub(pattern, replacement, shell, flags=re.IGNORECASE)
        else:
            shell = re.sub(pattern, replacement.replace("\\", "\\\\"), shell, flags=re.IGNORECASE)
    return shell, sections


def contents_row(sections, want_toc, want_ctl):
    nav = ""
    if want_toc and sections:
        links = "\n".join(
            f'      <a class="pill" href="#{ident}">{title}</a>' for ident, title in sections
        )
        nav = f'\n    <nav class="toc">\n{links}\n    </nav>'
    ctl = ""
    if want_ctl:
        ctl = (
            '\n    <div class="ctl-row">\n'
            '      <button class="ctl" id="expand-all" type="button">Expand all</button>\n'
            '      <button class="ctl" id="collapse-all" type="button">Collapse all</button>\n'
            "    </div>"
        )
    if not nav and not ctl:
        return ""
    return f'<div class="toc-row">{nav}{ctl}\n  </div>'


def place_rows(body, sections, doc_attrs, has_details):
    """Insert the contents/control row. Defaults are overridable, never forced."""
    explicit_ctl = CTL_SLOT in body
    want_toc = doc_attrs.get("toc") != "off" and (
        doc_attrs.get("toc") == "on" or TOC_SLOT in body or len(sections) >= 4
    )
    want_ctl = doc_attrs.get("ctl") != "off" and has_details

    body = body.replace(CTL_SLOT, contents_row([], False, want_ctl), 1)
    row = contents_row(sections, want_toc, want_ctl and not explicit_ctl)

    if TOC_SLOT in body:
        body = body.replace(TOC_SLOT, row, 1)
    elif AUTO_SLOT in body:
        body = body.replace(AUTO_SLOT, row, 1)
    elif row:
        body = row + "\n\n  " + body
    for slot in (TOC_SLOT, AUTO_SLOT, CTL_SLOT):
        body = re.sub(r"\n*\s*" + slot, "", body)
    return body


# ---------------------------------------------------------------- assembly


def git(*args):
    try:
        out = subprocess.run(
            ["git", *args], capture_output=True, text=True, timeout=5, check=False
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    return out.stdout.strip() if out.returncode == 0 else ""


def strip_tags(html):
    return re.sub(r"\s+", " ", re.sub(r"<[^>]+>", "", html)).strip()


def build(fragment, template, opts):
    shell, blocks = extract_literals(fragment)
    validate(shell, allowed_classes(template))

    doc = re.search(r"<doc\b((?:\"[^\"]*\"|'[^']*'|[^>])*)>", shell, re.IGNORECASE)
    doc_attrs = parse_attrs(doc.group(1)) if doc else {}
    shell = re.sub(r"</?doc\b(?:\"[^\"]*\"|'[^']*'|[^>])*>", "", shell, flags=re.IGNORECASE)

    heading = re.search(r"<h1\b[^>]*>(.*?)</h1\s*>", shell, re.DOTALL | re.IGNORECASE)
    if not heading:
        raise RenderError("fragment has no <h1>")
    standfirst = re.search(r"<standfirst\s*>(.*?)</standfirst\s*>", shell, re.DOTALL | re.IGNORECASE)
    shell = shell.replace(heading.group(0), "", 1)
    if standfirst:
        shell = shell.replace(standfirst.group(0), "", 1)

    body, sections = expand(shell, doc_attrs.get("numbering") != "off")
    for index, (block, newlines) in enumerate(blocks):
        body = body.replace(f"\x00{index}\x00" + "\n" * newlines, block)
    body = place_rows(body, sections, doc_attrs, "<details" in body).strip()

    lead = f'\n    <p class="standfirst">{standfirst.group(1).strip()}</p>' if standfirst else ""
    footer = [f"<span><b>repo</b> {opts.repo}"]
    footer[0] += f" @ {opts.branch}</span>" if opts.branch else "</span>"
    footer.append(f"<span><b>model</b> {opts.model}</span>")

    content = (
        f'<header class="topbar">\n'
        f'  <div class="brand">{opts.repo}<span> · htmldoc</span></div>'
        f'<div class="topbar-meta">{opts.date}</div>\n'
        f"</header>\n"
        f"<main>\n"
        f'  <div class="doc-head">\n'
        f'    <span class="pill pill-type">{opts.type}</span>\n'
        f"    <h1>{heading.group(1).strip()}</h1>{lead}\n"
        f"  </div>\n\n"
        f"  {body}\n"
        f"</main>\n"
        f'<footer class="foot">{"".join(footer)}</footer>'
    )
    title = escape(f"{strip_tags(heading.group(1))} · {opts.repo} · htmldoc")
    return template.replace(TITLE_MARKER, title).replace(CONTENT_MARKER, content)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("fragment", help="path to the semantic fragment")
    parser.add_argument("--type", required=True, help="Plan, Research, Walkthrough, …")
    parser.add_argument("--slug", required=True, help="short kebab-case topic")
    parser.add_argument("--model", required=True, help="model name for the footer")
    parser.add_argument("--out", help="output path (default: ~/.cache/htmldoc/…)")
    opts = parser.parse_args()

    toplevel = git("rev-parse", "--show-toplevel")
    opts.repo = Path(toplevel).name if toplevel else Path.cwd().name
    opts.branch = git("rev-parse", "--abbrev-ref", "HEAD")
    opts.date = date.today().isoformat()

    root = Path(__file__).resolve().parent
    template = (root / "template.html").read_text()
    if template.count(CONTENT_MARKER) != 1 or template.count(TITLE_MARKER) != 1:
        print("error: template markers are missing or duplicated", file=sys.stderr)
        return 2

    try:
        document = build(Path(opts.fragment).read_text(), template, opts)
    except RenderError as error:
        where = f" at line {error.line}" if error.line else ""
        print(f"error: {error}{where}", file=sys.stderr)
        if error.hint:
            print(f"       {error.hint}", file=sys.stderr)
        return 2

    default = Path.home() / ".cache/htmldoc" / f"{opts.repo}-{opts.slug}-{opts.date}.html"
    output = Path(opts.out).expanduser() if opts.out else default
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(document)
    print(output.resolve())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
