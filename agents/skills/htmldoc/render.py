#!/usr/bin/env python3
"""Insert an htmldoc content fragment into the static self-contained shell."""

from html import escape
from html.parser import HTMLParser
from pathlib import Path
import re
import sys

CONTENT_MARKER = "<!-- HTMLDOC_CONTENT -->"
TITLE_MARKER = "<!-- HTMLDOC_TITLE -->"
FORBIDDEN = re.compile(r"<(?:/?(?:html|head|body)|/?(?:style|script)|link)\b", re.IGNORECASE)


class MetadataParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.capture = None
        self.h1 = []
        self.repo = []

    def handle_starttag(self, tag, attrs):
        classes = dict(attrs).get("class", "").split()
        if tag == "h1":
            self.capture = self.h1
        elif "brand" in classes:
            self.capture = self.repo

    def handle_endtag(self, tag):
        if tag == "h1" or (tag == "div" and self.capture is self.repo):
            self.capture = None

    def handle_data(self, data):
        if self.capture is not None:
            self.capture.append(data)


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {Path(sys.argv[0]).name} FRAGMENT OUTPUT", file=sys.stderr)
        return 2

    root = Path(__file__).resolve().parent
    fragment = Path(sys.argv[1]).read_text()
    if FORBIDDEN.search(fragment):
        print("fragment contains a document-shell or executable tag", file=sys.stderr)
        return 2

    template = (root / "template.html").read_text()
    if template.count(CONTENT_MARKER) != 1 or template.count(TITLE_MARKER) != 1:
        print("template markers are missing or duplicated", file=sys.stderr)
        return 2

    metadata = MetadataParser()
    metadata.feed(fragment)
    heading = "".join(metadata.h1).strip() or "Document"
    repo = "".join(metadata.repo).split("·", 1)[0].strip() or "project"
    title = escape(f"{heading} · {repo} · htmldoc")

    output = Path(sys.argv[2]).expanduser()
    output.parent.mkdir(parents=True, exist_ok=True)
    document = template.replace(TITLE_MARKER, title).replace(CONTENT_MARKER, fragment.strip())
    output.write_text(document)
    print(output.resolve())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
