import assert from "node:assert/strict";
import { test } from "node:test";
import { stripVTControlCharacters } from "node:util";
import { visibleWidth } from "@earendil-works/pi-tui";
import footer from "../extensions/user/footer.ts";

function setup(
  sessionName?: string,
  reasoning = true,
  fg = (_color: string, text: string) => text,
) {
  let start: Function;
  let component: { render(width: number): string[] };
  footer({ on: (_event, handler) => { start = handler; } } as any);
  const theme = { fg };
  start!({}, {
    model: { id: "test-model", reasoning, contextWindow: 100_000 },
    thinkingLevel: "high",
    sessionManager: {
      getSessionName: () => sessionName,
      getEntries: () => [],
      getLeafId: () => null,
    },
    getContextUsage: () => undefined,
    ui: {
      setEditorComponent: () => {},
      setFooter: (factory: Function) => {
        component = factory({}, theme, { getExtensionStatuses: () => new Map() });
      },
    },
  });
  return (width = 100) => component!.render(width)[0];
}

test("session name follows model and reasoning", () => {
  assert.match(setup("My session")(), /^test-model · high · My session/);
});

test("unnamed sessions have no extra separator", () => {
  assert.match(setup("  ")(), /^test-model · high  /);
});

test("session name follows models without reasoning", () => {
  assert.match(setup("My session", false)(), /^test-model · My session/);
});

test("long session names fit narrow terminals", () => {
  const render = setup("界".repeat(200));
  for (const width of [0, 1, 10, 40, 80]) {
    assert.ok(visibleWidth(render(width)) <= width);
  }
});

test("long session names truncate before the right-hand stats", () => {
  const line = setup("A very long session name ".repeat(20))(60);
  assert.match(stripVTControlCharacters(line), /^test-model · high · .*…  \?\/100k \(auto\)$/);
  assert.equal(visibleWidth(line), 60);
});

test("the truncation ellipsis retains the session name's dim styling", () => {
  const render = setup("A very long session name ".repeat(20), true, (color, text) =>
    color === "dim" ? `\x1b[90m${text}\x1b[39m` : text,
  );
  assert.ok(render(60).includes("\x1b[90m…\x1b[39m"));
});

test("session names disappear when only the model and stats fit", () => {
  const line = setup("My session")(32);
  assert.match(line, /^test-model · high  \?\/100k \(auto\)$/);
  assert.equal(visibleWidth(line), 32);
});

test("session names stay on one line", () => {
  assert.match(setup("My\nsession\tname")(), /^test-model · high · My session name/);
});
