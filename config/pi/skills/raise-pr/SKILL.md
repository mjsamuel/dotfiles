---
name: raise-pr
description: Use when asked to raise/create or update a PR.
---

## Guiding light

Be as concise as possible - use few words and more pictures/diagrams.

## Title

PR titles usually become commit messages, so follow the repository's title conventions.
Prefer a human-readable title that explains why the change matters.

## Body

The following structure should be used in lieu of any project conventions:

```md
### Problem

### Solution

### Validation

{{ A validation checklist }}

<details>
<summary>Demo</summary>

{{
    A place to put screenshots/videos that demo the change.
    Can omit the details/summary entirely if there's nothing to demo.
}}

</details>
```

## Attachments

The GitHub CLI now supports adding attachments!

For example:

```sh
gh pr create \
  --title "PULL-REQUEST-TITLE" \
  --body-file PATH/TO/BODY-FILE \
  --attach PATH/TO/FIRST-IMAGE \
  --attach PATH/TO/SECOND-IMAGE
```

## Stacked branches

When raising multiple PRs in a stack append this block to the end of the description:

```md
---

This is **part 3 of 3** in a stack:

- `3` https://github.com/mjsamuel/dotfiles/pull/3 👈
- `2` https://github.com/mjsamuel/dotfiles/pull/2
- `1` https://github.com/mjsamuel/dotfiles/pull/1
```

Update 'part X of Y', the list entries, and move '👈' to mark the current PR:
