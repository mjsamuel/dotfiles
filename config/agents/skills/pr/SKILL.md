---
name: pr
description: PR conventions. Use when asked to create or update a PR.
---

## Title

Unless the project specifies otherwise:

```text
[TICKET-123] [X/Y] <type>[optional scope]: <description>
```

- Omit the ticket if none is associated; never invent one.
- Include `[X/Y]` only for stacks: position/total, matching the body's stack block.
- Use Conventional Commits (`feat`, `fix`, `refactor`, etc.), with optional scope.
- Keep the description concise and specific; PR titles often become commit messages when merged.

## Body

Use this structure unless the project specifies otherwise. Aim for the brevity, give reviewers the problem, changed behavior, rollout implications, and evidence - not a walkthrough of the diff.

```md
<!--
For a small change, aim for roughly 100–200 words, not a quota. Add detail only
when needed to understand behavior, risk, or verification.
Don't repeat the title, enumerate changed files, or narrate implementation details
visible in the diff. Name symbols only when needed to understand behavior or rollout.
Before publishing, replace all instructional comments and cut any sentence that
does not help a reviewer understand the change, its risk, or the evidence.
-->

<!--
Open with one or two plain-language sentences: what is missing or wrong, then what
this PR changes and why. No opening heading or generic preamble.
Prefer a small fenced `text` flow diagram when it explains sequencing or failure
paths more clearly than prose, including a failure/retry branch if useful.
Omit it when it adds nothing; use Mermaid only when the extra structure helps.
-->

### Rollout

<!--
Omit this entire section unless there is something actionable or non-obvious to
say: activation conditions, flags, deploy order, or exposure before activation.
Distinguish what is possible today from what requires future changes;
don't add boilerplate “no rollout needed”.
-->

<details>
<summary><h3>Validation</h3></summary>

<!--
Keep validation collapsed and concise: a checklist of verified results [x] and
important checks not performed [ ]. State meaningful coverage and gaps; include
counts only when verified. Never imply an unrun check passed.
Include screenshots or videos where useful; use a table only if easier to scan.
-->

</details>
```

Run prose through the `/bro` skill before publishing.

## Attachments

Attach images with the GitHub CLI:

```sh
gh pr create \
  --title "PULL-REQUEST-TITLE" \
  --body-file PATH/TO/BODY-FILE \
  --attach PATH/TO/FIRST-IMAGE \
  --attach PATH/TO/SECOND-IMAGE
```

## Stacked branches

For stacked PRs, append this block to each description:

```md
---

This is **part 3 of 3** in a stack:

- `3` https://github.com/mjsamuel/dotfiles/pull/3 👈
- `2` https://github.com/mjsamuel/dotfiles/pull/2
- `1` https://github.com/mjsamuel/dotfiles/pull/1
```

Update **part X of Y** and the PR links, and move 👈 to the current PR.
