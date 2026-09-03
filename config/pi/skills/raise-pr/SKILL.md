---
name: raise-pr
description: Use when asked to raise or create a PR.
---

Before raising, check whether a PR for this branch already exists. If one does, report it instead of opening a duplicate.

Determine the intended PR base. Use the parent branch for an unmerged stack; otherwise discover the repository's default branch rather than assuming `main` or `master`. Review the diff against that base to make sure its contents match the goal, then use the same base when creating the PR.

PR titles usually become commit messages, so follow the repository's title conventions. Look at recently merged PRs and Git history for examples. Prefer a concise, human-readable title that explains why the change matters.

Open the description with a simple explanation of the problem based on the user's original goal, then briefly explain the solution. Do not lead with an implementation inventory

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
