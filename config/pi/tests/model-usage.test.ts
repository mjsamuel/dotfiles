import assert from "node:assert/strict";
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { stripVTControlCharacters } from "node:util";
import modelUsage from "../extensions/user/model-usage.ts";
import type { TuiMouseEvent } from "@earendil-works/pi-tui";

async function monthlyDashboard() {
  const root = await mkdtemp(join(tmpdir(), "pi-usage-monthly-test-"));
  const previousRoot = process.env.PI_CODING_AGENT_SESSION_DIR;
  process.env.PI_CODING_AGENT_SESSION_DIR = root;
  try {
    let open: Function;
    let dashboard: any;
    modelUsage({
      registerFlag: () => {},
      on: () => {},
      registerCommand: (_name: string, command: { handler: Function }) => { open = command.handler; },
    } as any);
    await open!("", {
      mode: "tui",
      ui: {
        custom: async (factory: Function) => {
          dashboard = factory(
            { mode: "fullscreen", terminal: { rows: 30 }, requestRender: () => {} },
            {
              getColorMode: () => "truecolor", getFgAnsi: () => "",
              fg: (_color: string, text: string) => text,
              bg: (_color: string, text: string) => text,
              bold: (text: string) => text,
            },
            {}, () => {},
          );
        },
      },
    });
    dashboard.handleInput("m");
    return dashboard;
  } finally {
    if (previousRoot === undefined) delete process.env.PI_CODING_AGENT_SESSION_DIR;
    else process.env.PI_CODING_AGENT_SESSION_DIR = previousRoot;
    await rm(root, { recursive: true, force: true });
  }
}

for (const mode of ["fullscreen", "regular"] as const) {
  test(`usage dashboard preserves ${mode} mouse reporting ownership`, async () => {
    const root = await mkdtemp(join(tmpdir(), "pi-usage-test-"));
    const previousRoot = process.env.PI_CODING_AGENT_SESSION_DIR;
    process.env.PI_CODING_AGENT_SESSION_DIR = root;
    try {
      let open: Function;
      modelUsage({
        registerFlag: () => {},
        on: () => {},
        registerCommand: (_name: string, command: { handler: Function }) => {
          open = command.handler;
        },
      } as any);

      const writes: string[] = [];
      let closed = 0;
      // Deliberately not named AltScreen: mode is the public contract.
      const tui = {
        mode,
        terminal: { rows: 30, write: (data: string) => writes.push(data) },
        requestRender: () => {},
      };
      const theme = {
        getColorMode: () => "truecolor",
        getFgAnsi: () => "",
      };
      await open!("", {
        mode: "tui",
        ui: {
          custom: async (factory: Function) => {
            const dashboard = factory(tui, theme, {}, () => { closed++; });
            dashboard.handleInput("q");
            dashboard.dispose();
            dashboard.dispose();
          },
        },
      });

      assert.equal(closed, 1);
      assert.deepEqual(writes, mode === "fullscreen" ? [] : [
        "\x1b[?1000h\x1b[?1006h",
        "\x1b[?1006l\x1b[?1000l",
      ]);
    } finally {
      if (previousRoot === undefined) delete process.env.PI_CODING_AGENT_SESSION_DIR;
      else process.env.PI_CODING_AGENT_SESSION_DIR = previousRoot;
      await rm(root, { recursive: true, force: true });
    }
  });
}

test("monthly periods use calendar boundaries across leap years and year changes", async (t) => {
  t.mock.method(Date, "now", () => new Date(2024, 2, 15).getTime());
  const dashboard = await monthlyDashboard();
  const date = (month: number) => new Date(2024, month, 1).getTime();
  assert.deepEqual(dashboard.period(3), {
    start: date(0), end: date(3), priorStart: date(-3),
    boundaries: [date(0), date(1), date(2), date(3)],
  });
  dashboard.handleInput("\x1b[D");
  assert.equal(dashboard.period(3).start, date(-3));
  assert.equal(dashboard.period(3).end, date(0));
  dashboard.handleInput("t");
  assert.equal(dashboard.period(3).start, date(0));
});

test("monthly totals assign boundary records once and compare with the prior period", async (t) => {
  t.mock.method(Date, "now", () => new Date(2024, 2, 15).getTime());
  const dashboard = await monthlyDashboard();
  dashboard.records = [
    [new Date(2023, 11, 31, 23, 59).getTime(), 2],
    [new Date(2024, 0, 1).getTime(), 3],
    [new Date(2024, 1, 29, 23, 59).getTime(), 5],
    [new Date(2024, 2, 1).getTime(), 7],
    [new Date(2024, 3, 1).getTime(), 11],
  ].map(([timestamp, cost]) => ({
    timestamp, cost, model: "test", provider: "test",
    input: 0, output: 0, cacheRead: 0, cacheWrite: 0,
  }));
  const data = dashboard.data(3);
  assert.deepEqual(data.buckets.map((bucket: any) => bucket.total), [3, 5, 7]);
  assert.deepEqual(data.buckets.map((bucket: any) => bucket.label), ["Jan 24", "Feb 24", "Mar 24"]);
  assert.equal(data.total, 15);
  assert.equal(data.groups[0].priorCost, 2);
});

test("monthly tab and shortcut render and switching granularity resets navigation", async () => {
  const dashboard = await monthlyDashboard();
  const lines = dashboard.render(120).map(stripVTControlCharacters);
  assert.match(lines[0], /Daily.*Weekly.*Monthly/);
  assert.match(lines.at(-1), /m monthly/);
  assert.match(lines.at(-1), /click\/scroll/);
  for (const [key, granularity] of [["d", "daily"], ["w", "weekly"], ["m", "monthly"]]) {
    dashboard.handleInput("\x1b[D");
    dashboard.handleInput(key);
    assert.equal(dashboard.granularity, granularity);
    assert.equal(dashboard.offset, 0);
  }
});

function mouseEvent(overrides: Partial<TuiMouseEvent>): TuiMouseEvent {
  return {
    type: "click", button: "left", x: 0, y: 0,
    screenX: 40, screenY: 10, width: 120, height: 30,
    shift: false, alt: false, ctrl: false,
    ...overrides,
  };
}

function clickControl(dashboard: any, label: string, row = 0) {
  const line = stripVTControlCharacters(dashboard.render(120)[row]);
  const x = line.indexOf(label);
  assert.ok(x >= 0, `${label} is rendered`);
  const event = mouseEvent({ x, y: row });
  assert.equal(dashboard.handleMouse({ ...event, type: "press" })?.handled, true);
  dashboard.handleMouse({ ...event, type: "release" });
  assert.equal(dashboard.handleMouse(event)?.handled, true);
}

test("fullscreen normalized clicks activate tabs, grouping, navigation and close once", async () => {
  const dashboard = await monthlyDashboard();
  let closed = 0;
  dashboard.done = () => { closed++; };
  for (const [label, granularity] of [["Daily", "daily"], ["Weekly", "weekly"], ["Monthly", "monthly"]]) {
    clickControl(dashboard, label);
    assert.equal(dashboard.granularity, granularity);
  }
  clickControl(dashboard, "Group:");
  assert.equal(dashboard.grouping, "provider");
  clickControl(dashboard, "‹", 1);
  assert.equal(dashboard.offset, 1);
  clickControl(dashboard, "›", 1);
  assert.equal(dashboard.offset, 0);
  clickControl(dashboard, "‹", 1);
  clickControl(dashboard, "latest", 1);
  assert.equal(dashboard.offset, 0);
  clickControl(dashboard, "close");
  assert.equal(closed, 1);
});

test("fullscreen wheel events navigate periods and suppress fallback scrolling", async () => {
  const dashboard = await monthlyDashboard();
  assert.equal(dashboard.handleMouse(mouseEvent({ type: "wheel", wheelDelta: -3 }))?.handled, true);
  assert.equal(dashboard.offset, 1);
  assert.equal(dashboard.handleMouse(mouseEvent({ type: "wheel", wheelDelta: 3 }))?.handled, true);
  assert.equal(dashboard.offset, 0);
  dashboard.handleMouse(mouseEvent({ type: "wheel", wheelDelta: 3 }));
  assert.equal(dashboard.offset, 0);
});

test("unrelated normalized mouse events do not activate controls", async () => {
  const dashboard = await monthlyDashboard();
  const line = stripVTControlCharacters(dashboard.render(120)[0]);
  const x = line.indexOf("Group:");
  for (const event of [
    mouseEvent({ x, type: "move" }),
    mouseEvent({ x, type: "drag" }),
    mouseEvent({ x, type: "release" }),
    mouseEvent({ x, button: "right" }),
    mouseEvent({ y: 2 }),
  ]) {
    assert.equal(dashboard.handleMouse(event), undefined);
  }
  assert.equal(dashboard.grouping, "model");
});

test("raw terminal mouse input still activates controls once", async () => {
  const dashboard = await monthlyDashboard();
  const line = stripVTControlCharacters(dashboard.render(120)[0]);
  const x = line.indexOf("Group:") + 1;
  dashboard.handleInput(`\x1b[<0;${x};1M`);
  dashboard.handleInput(`\x1b[<0;${x};1m`);
  assert.equal(dashboard.grouping, "provider");
  dashboard.handleInput("\x1b[<64;1;1M");
  assert.equal(dashboard.offset, 1);
  dashboard.handleInput("\x1b[<65;1;1M");
  assert.equal(dashboard.offset, 0);
});

test("provider grouping merges OpenAI and Codex without changing model grouping", async (t) => {
  t.mock.method(Date, "now", () => new Date(2024, 2, 15).getTime());
  const dashboard = await monthlyDashboard();
  dashboard.records = [
    { provider: "openai", model: "gpt", cost: 3, timestamp: new Date(2024, 2, 1).getTime() },
    { provider: "openai-codex", model: "codex", cost: 5, timestamp: new Date(2024, 2, 2).getTime() },
    { provider: "openai-codex", model: "codex", cost: 2, timestamp: new Date(2024, 1, 1).getTime() },
    { provider: "anthropic", model: "claude", cost: 1, timestamp: new Date(2024, 2, 3).getTime() },
  ].map((record) => ({ ...record, input: 10, output: 5, cacheRead: 0, cacheWrite: 0 }));
  dashboard.handleInput("g");
  const { groups, buckets, total } = dashboard.data(1);
  assert.deepEqual(groups.map((group: any) => group.key), ["openai", "anthropic"]);
  assert.equal(groups[0].cost, 8);
  assert.equal(groups[0].priorCost, 2);
  assert.equal(groups[0].input, 20);
  assert.equal(groups[0].output, 10);
  assert.equal(buckets[0].values.get("openai"), 8);
  assert.equal(buckets[0].values.has("openai-codex"), false);
  assert.equal(total, 9);
  assert.equal(dashboard.colorMap.has("openai-codex"), false);
  assert.equal(dashboard.colorMap.has("openai"), true);
  dashboard.handleInput("g");
  assert.deepEqual(dashboard.data(1).groups.map((group: any) => group.key), ["codex", "gpt", "claude"]);
  assert.equal(dashboard.records[1].provider, "openai-codex");
});
