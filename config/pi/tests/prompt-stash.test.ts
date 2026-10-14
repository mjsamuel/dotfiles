import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, statSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { after, test } from "node:test";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const stateHome = mkdtempSync(join(tmpdir(), "pi-prompt-stash-"));
const previousStateHome = process.env.XDG_STATE_HOME;
process.env.XDG_STATE_HOME = stateHome;
const { registerPromptStash } = await import("../extensions/user/prompt-stash.ts");
if (previousStateHome === undefined) delete process.env.XDG_STATE_HOME;
else process.env.XDG_STATE_HOME = previousStateHome;
after(() => rmSync(stateHome, { recursive: true, force: true }));
const stashPath = join(stateHome, "pi", "prompt-stash");

function setup(initialPrompt = "") {
  let prompt = initialPrompt;
  let handler!: (ctx: ExtensionContext) => void | Promise<void>;
  const notifications: string[] = [];
  registerPromptStash({
    registerShortcut(key, options) {
      assert.equal(key, "ctrl+shift+s");
      handler = options.handler;
    },
  } as ExtensionAPI);
  const ctx = {
    ui: {
      getEditorText: () => prompt,
      setEditorText: (text: string) => { prompt = text; },
      notify: (message: string) => notifications.push(message),
    },
  } as unknown as ExtensionContext;
  return {
    press: () => handler(ctx),
    get prompt() { return prompt; },
    notifications,
  };
}

test("stashes and restores before Pi's post-keypress redraw", () => {
  const text = "A draft\nwith multiple lines 🐱";
  const editor = setup(text);
  assert.equal(editor.press(), undefined);
  assert.equal(editor.prompt, "");
  assert.equal(readFileSync(stashPath, "utf8"), text);
  assert.equal(statSync(stashPath).mode & 0o777, 0o600);
  assert.equal(editor.press(), undefined);
  assert.equal(editor.prompt, text);
  assert.throws(() => readFileSync(stashPath), { code: "ENOENT" });
});

test("rapid presses toggle without overlapping file operations", () => {
  const editor = setup("draft");
  for (let i = 0; i < 10; i++) editor.press();
  assert.equal(editor.prompt, "draft");
  assert.deepEqual(editor.notifications, []);
});

test("a stash survives extension re-registration", () => {
  setup("persistent draft").press();
  const editor = setup();
  editor.press();
  assert.equal(editor.prompt, "persistent draft");
});

test("an empty editor with no stash is unchanged", () => {
  const editor = setup();
  editor.press();
  assert.equal(editor.prompt, "");
  assert.deepEqual(editor.notifications, []);
});

test("failed persistence keeps the draft and reports an error", () => {
  mkdirSync(stashPath);
  try {
    const editor = setup("do not lose this draft");
    editor.press();
    assert.equal(editor.prompt, "do not lose this draft");
    assert.match(editor.notifications[0], /Could not update prompt stash:/);
  } finally {
    rmSync(stashPath, { recursive: true });
  }
});
