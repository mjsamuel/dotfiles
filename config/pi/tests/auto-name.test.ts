import assert from "node:assert/strict";
import { setImmediate } from "node:timers/promises";
import { test } from "node:test";
import type { Api, Model } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import autoName, { cleanSessionName, latestHaiku } from "../extensions/user/auto-name.ts";

function model(id: string, name: string, provider = "anthropic") {
  return { id, name, provider } as Model<Api>;
}

function setup() {
  const handlers = new Map<string, Function>();
  let name: string | undefined;
  let sessionId = "first";
  let calls = 0;
  let signal: AbortSignal | undefined;
  let request: unknown;
  let resolve!: (value: unknown) => void;
  const notifications: string[] = [];
  const models = [model("claude-haiku-4-5-20251001", "Claude Haiku 4.5")];
  autoName({
    on: (event: string, handler: Function) => handlers.set(event, handler),
    getSessionName: () => name,
    setSessionName: (value: string) => { name = value; },
  } as unknown as ExtensionAPI);
  const ctx = {
    hasUI: true,
    ui: { notify: (message: string) => notifications.push(message) },
    sessionManager: { getSessionId: () => sessionId },
    modelRegistry: {
      getAvailable: () => models,
      streamSimple: (_model: unknown, context: unknown, options: { signal: AbortSignal }) => {
        calls++;
        signal = options.signal;
        request = context;
        return { result: () => new Promise((done) => { resolve = done; }) };
      },
    },
  } as unknown as ExtensionContext;
  return {
    models, notifications,
    get name() { return name; },
    get calls() { return calls; },
    get signal() { return signal; },
    get request() { return request; },
    start: (prompt = "Fix the login bug", messageType = "user") =>
      handlers.get("before_agent_start")!({ prompt, messageType }, ctx),
    emit: (event: string) => handlers.get(event)!({}, ctx),
    rename: (value: string) => { name = value; },
    switchSession: () => { sessionId = "second"; },
    finish: async (text = "Fix login authentication", stopReason = "stop") => {
      resolve({ content: [{ type: "text", text }], stopReason });
      await setImmediate();
    },
  };
}

test("selects the newest Anthropic Haiku version and dated release", () => {
  const newest = model("claude-haiku-4-5-20251001", "Claude Haiku 4.5");
  const models = [
    newest,
    model("claude-3-5-haiku-20241022", "Claude 3.5 Haiku"),
    model("claude-haiku-4-5", "Claude Haiku 4.5"),
    model("claude-haiku-99", "Claude Haiku 99", "openrouter"),
    model("claude-opus-5", "Claude Opus 5"),
  ];
  assert.equal(latestHaiku(models), newest);
  const future = model("claude-haiku-4-10", "Claude Haiku 4.10");
  assert.equal(latestHaiku([...models, future]), future);
  assert.equal(latestHaiku([]), undefined);
});

test("cleans and bounds generated titles", () => {
  assert.equal(cleanSessionName('  **"Fix login bug"**\nExtra explanation'), "Fix login bug");
  assert.equal(cleanSessionName(""), "");
  assert.equal(cleanSessionName("x".repeat(100)).length, 80);
});

test("names asynchronously and prevents duplicate requests", async () => {
  const state = setup();
  assert.equal(state.start(), undefined);
  state.start();
  assert.equal(state.calls, 1);
  assert.equal(state.name, undefined);
  await state.finish();
  assert.equal(state.name, "Fix login authentication");
  state.start();
  assert.equal(state.calls, 1);
});

test("preserves existing and manually assigned names", async () => {
  const state = setup();
  state.rename("My title");
  state.start();
  assert.equal(state.calls, 0);
  const pending = setup();
  pending.start();
  pending.rename("Manual title");
  await pending.finish();
  assert.equal(pending.name, "Manual title");
});

test("ignores custom messages and blank prompts", () => {
  const state = setup();
  state.start("Custom prompt", "custom");
  state.start("  ");
  assert.equal(state.calls, 0);
});

test("bounds prompt input", async () => {
  const state = setup();
  state.start("x".repeat(5000));
  assert.equal((state.request as { messages: { content: string }[] }).messages[0].content.length, 4000);
  await state.finish();
});

test("cancels stale requests on lifecycle and name changes", async () => {
  for (const event of ["session_start", "session_shutdown", "session_info_changed"]) {
    const state = setup();
    state.start();
    state.emit(event);
    assert.equal(state.signal?.aborted, true);
    await state.finish();
    assert.equal(state.name, undefined);
  }
});

test("does not name a different session", async () => {
  const state = setup();
  state.start();
  state.switchSession();
  await state.finish();
  assert.equal(state.name, undefined);
});

test("reports missing credentials once and can retry", async () => {
  const state = setup();
  state.models.length = 0;
  state.start();
  state.start();
  assert.equal(state.notifications.length, 1);
  assert.match(state.notifications[0], /login anthropic/);
  state.models.push(model("claude-haiku-4-5", "Claude Haiku 4.5"));
  state.start();
  await state.finish();
  assert.equal(state.name, "Fix login authentication");
});

test("failed, truncated, and empty responses leave sessions unnamed and allow retry", async () => {
  for (const reason of ["error", "aborted", "length", "stop"]) {
    const state = setup();
    state.start();
    await state.finish("", reason);
    assert.equal(state.name, undefined);
    state.start();
    await state.finish();
    assert.equal(state.name, "Fix login authentication");
  }
});
