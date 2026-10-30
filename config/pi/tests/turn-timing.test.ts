import assert from "node:assert/strict";
import { test } from "node:test";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import turnTiming, { formatDuration } from "../extensions/user/turn-timing.ts";

function setup() {
  const handlers = new Map<string, Function>();
  const entries: { type: string; data: any }[] = [];
  let render!: Function;
  let outputPad: 0 | 1 | undefined;
  turnTiming({
    on: (event: string, handler: Function) => handlers.set(event, handler),
    getSettings: () => ({ outputPad }),
    registerEntryRenderer: (_type: string, renderer: Function) => { render = renderer; },
    appendEntry: (type: string, data: unknown) => entries.push({ type, data }),
  } as unknown as ExtensionAPI);
  return {
    entries,
    setOutputPad: (value: 0 | 1) => { outputPad = value; },
    emit: (event: string, data = {}, mode = "tui") => handlers.get(event)!(data, { mode }),
    render: (data: unknown, width = 80) => render({ data }, {}, {
      fg: (_color: string, text: string) => text,
    })?.render(width),
  };
}

test("formats short, minute, and hour durations", () => {
  assert.equal(formatDuration(0), "1s");
  assert.equal(formatDuration(2_100), "2s");
  assert.equal(formatDuration(59_600), "1m 0s");
  assert.equal(formatDuration(125_000), "2m 5s");
  assert.equal(formatDuration(3_661_000), "1h 1m 1s");
});

test("records one durable timing entry after all runs settle", () => {
  const state = setup();
  state.emit("before_agent_start");
  state.emit("before_agent_start");
  assert.equal(state.entries.length, 0);
  state.emit("agent_settled", { aborted: false });
  assert.equal(state.entries.length, 1);
  assert.equal(state.entries[0].type, "turn-timing");
  assert.ok(state.entries[0].data.durationMs >= 0);
  assert.equal(state.entries[0].data.aborted, false);
  state.emit("agent_settled", { aborted: false });
  assert.equal(state.entries.length, 1);
  state.emit("before_agent_start");
  state.emit("agent_settled", { aborted: true });
  assert.equal(state.entries[1].data.aborted, true);
});

test("skips non-TUI runs and clears timing on shutdown", () => {
  const state = setup();
  state.emit("before_agent_start", {}, "json");
  state.emit("agent_settled");
  state.emit("before_agent_start");
  state.emit("session_shutdown");
  state.emit("agent_settled");
  assert.equal(state.entries.length, 0);
});

test("renders completion and interruption, wrapping at narrow widths", () => {
  const state = setup();
  const data = { durationMs: 2_000, completedAt: Date.now(), aborted: false };
  assert.match(state.render(data).join("\n"), /^ Worked for 2s · done /);
  state.setOutputPad(0);
  assert.match(state.render(data).join("\n"), /^Worked for 2s · done /);
  state.setOutputPad(1);
  assert.match(state.render(data).join("\n"), /^ Worked for 2s · done /);
  assert.match(state.render({ ...data, aborted: true }).join("\n"), /· stopped /);
  assert.ok(state.render(data, 15).length > 1);
  assert.equal(state.render(undefined), undefined);
});
