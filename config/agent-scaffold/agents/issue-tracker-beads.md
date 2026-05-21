# Issue tracker: Beads

Issues and PRDs for this repo live in a [Beads](https://github.com/gastownhall/beads) issue database backed by [Dolt](https://github.com/dolthub/dolt). Use the `bd` CLI for all operations.

## Conventions

- **Create an issue**: `bd create "..." --description "..." -t bug|feature|task|epic|chore|decision -p 0-4 --json`. Use `--deps discovered-from:<issue-id>` when creating newly discovered follow-up work.
- **Read an issue**: `bd show <issue-id> --json`. Use `bd comments <issue-id> --json` as well when you need the full discussion thread.
- **List issues**: `bd list --status open --json` with appropriate `--label`, `--label-any`, `--type`, and `--priority` filters.
- **Find available work**: `bd ready --json` for unblocked issues, or `bd blocked --json` for stuck work.
- **Start work**: `bd update <issue-id> --claim --json`.
- **Comment on an issue**: `bd comments add <issue-id> "..."` or `bd comments add <issue-id> -f <file>`.
- **Apply / remove labels**: `bd label add <issue-id> <label>` / `bd label remove <issue-id> <label>`.
- **Close**: `bd close <issue-id> --reason "..." --json`
- **Sync**: run `bd dolt push` after creating, updating, commenting on, labeling, or closing issues if the repo has a Dolt remote configured. Always push at the end of the session.

`bd` operates on the current repo's Beads workspace and `.beads` database.

## When a skill says "publish to the issue tracker"

Create a Beads issue with `bd create`.

## When a skill says "fetch the relevant ticket"

Run `bd show <issue-id> --json`, and also `bd comments <issue-id> --json` if comment history matters.
