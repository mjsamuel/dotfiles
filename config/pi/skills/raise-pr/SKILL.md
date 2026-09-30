---
name: raise-pr
description: Use when asked to raise or create a PR.
---

## Title

PR titles usually become commit messages, so follow the repository's title conventions.

Look at recently merged PRs and Git history for examples. Prefer a concise, human-readable title that explains why the change matters.

## Body

The body should be similarly concise and human readable. Use big pictures and few words.

The following structure should be used in lieu of any project conventions:

```md
### Problem

### Solution

### Validation

- A validation checklist

<details>
<summary>Demo</summary>

{{ A place to put any screenshots or videos that demo the change }}

</details>
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
