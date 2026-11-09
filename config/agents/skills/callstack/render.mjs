#!/usr/bin/env node
// Usage: node render.mjs <scenarios.json>
// Prints a text summary to stdout, writes <file>.html next to the JSON, warns on stderr.
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const file = process.argv[2];
if (!file) {
  console.error("usage: node render.mjs <scenarios.json>");
  process.exit(1);
}
const data = JSON.parse(readFileSync(file, "utf8"));
const step = (s) => (s == null ? null : typeof s === "string" ? { text: s } : s);
const plain = (s) => s.replace(/\*\*/g, "").replace(/`/g, "");

// Validate
const warnings = [];
if (!data.title) warnings.push("missing title");
if (!data.scenarios?.length) warnings.push("no scenarios");
let rowCount = 0;
(data.scenarios ?? []).forEach((sc, i) => {
  const p = `scenario ${i + 1}`;
  if (!sc.name) warnings.push(`${p}: missing name`);
  if (!sc.rows?.length) warnings.push(`${p}: no rows`);
  (sc.rows ?? []).forEach((r, j) => {
    rowCount++;
    const q = `${p} row ${j + 1}`;
    const isSame = "same" in r;
    const isPair = "before" in r || "after" in r;
    if (isSame === isPair) return warnings.push(`${q}: use either "same" or "before"/"after"`);
    const steps = isSame ? [step(r.same)] : [step(r.before), step(r.after)];
    if (isPair && !steps[0] && !steps[1]) warnings.push(`${q}: both sides are null`);
    if (isPair && steps[0] && steps[1] && JSON.stringify(steps[0]) === JSON.stringify(steps[1]))
      warnings.push(`${q}: before and after are identical; use "same"`);
    for (const s of steps.filter(Boolean)) {
      if (!s.text) warnings.push(`${q}: step missing text`);
      else if (plain(s.text).split(/\s+/).length > 22) warnings.push(`${q}: text is long`);
    }
  });
});
if (rowCount > 24) warnings.push(`${rowCount} rows; aim for under 20`);

// Text summary
const out = [];
const counts = { add: 0, del: 0, same: 0 };
out.push(data.summary ? `${data.title} — ${plain(data.summary)}` : data.title);
out.push("legend: - before  + after  · unchanged");
(data.scenarios ?? []).forEach((sc, i) => {
  out.push("", `${i + 1}. ${sc.name}${sc.note ? `  (${plain(sc.note)})` : ""}`);
  const line = (mark, s) => {
    out.push(`   ${mark} ${plain(s.text ?? "")}`);
    if (s.call) out.push(`       ${s.call}`);
  };
  for (const r of sc.rows ?? []) {
    if ("same" in r) { counts.same++; line("·", step(r.same)); continue; }
    const [b, a] = [step(r.before), step(r.after)];
    if (b) { counts.del++; line("-", b); }
    if (a) { counts.add++; line("+", a); }
  }
});
console.log(out.join("\n"));

// HTML
const here = dirname(fileURLToPath(import.meta.url));
const tpl = readFileSync(join(here, "template.html"), "utf8");
const json = JSON.stringify(data).replace(/</g, "\\u003c");
const outFile = file.replace(/\.json$/, "") + ".html";
writeFileSync(outFile, tpl.replace("__TITLE__", () => escapeHtml(data.title ?? "Call flow")).replace("__DATA__", () => json));
console.log(`\n${outFile}`);

for (const w of warnings) console.error(`warn: ${w}`);
if (warnings.length) process.exitCode = 2;

function escapeHtml(s) {
  return s.replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);
}
