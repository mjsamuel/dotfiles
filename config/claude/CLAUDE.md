## Plan Mode

- Make the plan extremely concise. Sacrifice grammar for the sake of concision.
- At the end of each plan, give me a list of unresolved questions to answer, if any.

## Code References

When referencing line numbers or code locations, ALWAYS include the full file path (e.g., 'src/foo/bar.ts:42' not just 'line 42').

## Searching

Use `rg` (ripgrep) instead of `grep`. It respects `.gitignore` and is faster.

## Github PRs

### Stacked branches

For each PR in a stack, append this block to the description. Update
`part X of Y`, the list entries, and move 👈 to mark the current PR:

```
---

This is **part 3 of 3 in a stack**:

- `3` https://github.com/mjsamuel/dotfiles/pull/3 👈
- `2` https://github.com/mjsamuel/dotfiles/pull/2
- `1` https://github.com/mjsamuel/dotfiles/pull/1
```
