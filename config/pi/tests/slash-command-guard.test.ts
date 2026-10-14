import assert from "node:assert/strict";
import { test } from "node:test";
import type { ExtensionAPI, ExtensionContext, InputEvent, InputEventResult } from "@earendil-works/pi-coding-agent";
import { registerSlashCommandGuard } from "../extensions/user/slash-command-guard.ts";

function setup() {
  let handler!: (event: InputEvent, ctx: ExtensionContext) => InputEventResult;
  const commands = ["exit", "skill:grilling", "review"];
  const notifications: string[] = [];
  registerSlashCommandGuard({
    on(event, callback) {
      assert.equal(event, "input");
      handler = callback;
    },
    getCommands: () => commands.map((name) => ({ name })),
  } as unknown as ExtensionAPI);
  const ctx = {
    ui: { notify: (message: string) => notifications.push(message) },
  } as unknown as ExtensionContext;
  return {
    commands,
    notifications,
    input: (text: string, source: InputEvent["source"] = "interactive") =>
      handler({ type: "input", text, source }, ctx),
  };
}

test("blocks unknown slash commands before model processing", () => {
  const { input, notifications } = setup();
  for (const text of ["/eixt", "/eixt args", "/", "/EXIT", "/tmp/file", "/skill:missing"]) {
    assert.deepEqual(input(text), { action: "handled" });
  }
  assert.equal(notifications.length, 6);
  assert.match(notifications[0], /Unknown command: \/eixt.*Not sent to the model/);
});

test("allows registered commands, skills, and templates with arguments", () => {
  const { input, notifications } = setup();
  for (const text of ["/exit", "/skill:grilling", "/skill:grilling my plan", "/review some code"]) {
    assert.deepEqual(input(text), { action: "continue" });
  }
  assert.deepEqual(notifications, []);
});

test("checks the current registry rather than a startup snapshot", () => {
  const { commands, input } = setup();
  assert.deepEqual(input("/new-command"), { action: "handled" });
  commands.push("new-command");
  assert.deepEqual(input("/new-command"), { action: "continue" });
});

test("leaves ordinary messages and extension-injected messages alone", () => {
  const { input, notifications } = setup();
  for (const text of ["hello", "mention /eixt", ""]) {
    assert.deepEqual(input(text), { action: "continue" });
  }
  assert.deepEqual(input("/tmp/file", "extension"), { action: "continue" });
  assert.deepEqual(notifications, []);
});

test("also blocks unknown commands submitted through RPC", () => {
  const { input } = setup();
  assert.deepEqual(input("/eixt", "rpc"), { action: "handled" });
});
