---
name: callstack
description: Visualize how a PR or diff changes the call flow - side-by-side before/after steps for real scenarios, with the calls (inputs/outputs) behind each step - as a text summary plus an interactive HTML page. Use when asked for a call stack, call flow, before/after, or flow visualization of a PR, branch, or diff.
---

You write a small JSON file of scenarios; `render.mjs` turns it into a text summary and an HTML page. Never hand-write the HTML.

## Procedure

1. Get the change: `gh pr diff <n>` or `git diff <base>...HEAD`. Run `--stat` first, then read hunks for source files. Skip tests, generated code, and lockfiles unless they change behavior.
2. Read the surrounding code at head and base (`gh api repos/<o>/<r>/contents/<path>?ref=<sha> -H "Accept: application/vnd.github.raw"` if there's no local checkout). Hunks alone hide the call flow.
3. Pick 1–4 scenarios: real things that happen at runtime ("SQS delivers a queued job"), not code units. Lead with the main path. Include an unchanged path when it proves a refactor is safe.
4. Write each scenario as steps in execution order, for both versions. Pair steps that replace each other in one row. Use `same` for steps that are identical in both.
5. Verify before writing. Copy `call` signatures from the source (base for `before`, head for `after`) and read every line you cite. If behavior depends on code you couldn't read (framework, runtime, another service), say so in the step with "probably".
6. Write `~/.cache/callstack/<repo>-<kebab-topic>-<YYYY-MM-DD>.json`, then run `node <skill-dir>/render.mjs <file>.json`. Fix any warnings.
7. Reply with the printed text in a `text` block, then the HTML path on its own line. Do not open it.

## Schema

```jsonc
{
  "title": "Order creation checks stock",           // what changed, plainly
  "summary": "Orders now fail fast when stock is short", // the verdict, ≤12 words
  "context": "acme/shop #123",                       // optional
  "link": "https://github.com/acme/shop/blob/<head-sha>/", // optional; prefixes after/same `at`
  "baseLink": "https://github.com/acme/shop/blob/<base-sha>/", // optional; prefixes before `at`
  "scenarios": [{
    "name": "Customer places an order",
    "note": "optional one-liner under the name",
    "rows": [
      { "same": "Route validates the request", "at": "src/routes/orders.ts:18" },
      { "before": null,
        "after": { "text": "**Checks stock** for every item",
                   "call": "checkStock(items: Item[]) → StockResult",
                   "at": "src/stock/check.ts:10" } },
      { "before": "Inserts the order", "after": "Inserts the order **unless `dryRun`**" }
    ]
  }]
}
```

- A row is either `{ "same": … }` or `{ "before": …, "after": … }`. Use `null` for a side with no step (added or removed).
- A step is a string, or `{ text, call?, at? }`. Strings and `text` allow `` `code` `` and `**bold**`; bold the words that differ.
- `call` shows the signature with inputs and output: `name(param: Type) → Return`. Add it where the signature matters, usually on changed rows.
- `text` describes behavior in plain words, ≤20 words. Name functions only when reviewers will look for them.
- Shorten types: drop packages and obvious generics.
- Keep it under about 20 rows in total.
