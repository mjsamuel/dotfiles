# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

## Before exploring, read these

- **`.mjsamuel/CONTEXT.md`** at the repo root, or
- **`.mjsamuel/CONTEXT-MAP.md`** at the repo root if it exists — it points at one `.mjsamuel/CONTEXT.md` per context. Read each one relevant to the topic.
- **`.mjsamuel/adr/`** — read ADRs that touch the area you're about to work in. In multi-context repos, also check `src/<context>/.mjsamuel/adr/` for context-scoped decisions.

If any of these files don't exist, **proceed silently**. Don't flag their absence; don't suggest creating them upfront. They get created lazily as terms or decisions actually get resolved.

## File structure

Single-context repo (most repos):

```
/
├── .mjsamuel/
│   ├── CONTEXT.md
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

Multi-context repo (presence of `.mjsamuel/CONTEXT-MAP.md` at the root):

```
/
├── .mjsamuel/
│   ├── CONTEXT-MAP.md
│   └── adr/                           ← system-wide decisions
└── src/
    ├── ordering/
    │   └── .mjsamuel/
    │       ├── CONTEXT.md
    │       └── adr/                   ← context-specific decisions
    └── billing/
        └── .mjsamuel/
            ├── CONTEXT.md
            └── adr/
```

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in `.mjsamuel/CONTEXT.md`. Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal — either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it so it can be resolved later).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0007 (event-sourced orders) — but worth reopening because…_
