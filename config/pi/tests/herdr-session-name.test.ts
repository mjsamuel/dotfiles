import assert from "node:assert/strict";
import { EventEmitter } from "node:events";
import net from "node:net";
import { setImmediate } from "node:timers/promises";
import { test } from "node:test";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

process.env.HERDR_ENV = "1";
process.env.HERDR_SOCKET_PATH = "/unused/herdr-test.sock";
process.env.HERDR_PANE_ID = "test-pane";
const { default: herdrSessionName } = await import("../extensions/user/herdr-session-name.ts");

test("reports only sidebar session names and clears them on shutdown", async (t) => {
  const requests: any[] = [];
  t.mock.method(net, "createConnection", () => {
    const socket = new EventEmitter() as any;
    socket.destroy = () => {};
    socket.write = (data: string) => {
      requests.push(JSON.parse(data));
      queueMicrotask(() => socket.emit("data", "ok"));
    };
    queueMicrotask(() => socket.emit("connect"));
    return socket;
  });
  const handlers = new Map<string, Function>();
  let name: string | undefined = "Existing session";
  herdrSessionName({
    on: (event: string, handler: Function) => handlers.set(event, handler),
    getSessionName: () => name,
  } as unknown as ExtensionAPI);
  const emit = async (event: string, data = {}, mode = "tui") => {
    handlers.get(event)!(data, { mode });
    await setImmediate();
  };
  const last = () => requests.at(-1).params;
  assert.deepEqual([...handlers.keys()], ["session_start", "session_info_changed", "session_shutdown"]);

  await emit("session_start", {}, "rpc");
  await emit("session_info_changed");
  assert.equal(requests.length, 0);

  await emit("session_start");
  assert.equal(requests.at(-1).method, "pane.report_metadata");
  assert.equal(last().tokens.session_name, "Existing session");
  assert.equal(last().applies_to_source, "herdr:pi");


  name = "generated or renamed session";
  await emit("session_info_changed");
  assert.equal(last().tokens.session_name, "Generated or renamed session");
  assert.equal(name, "generated or renamed session");


  name = undefined;
  await emit("session_start");
  assert.equal(last().tokens.session_name, "New thread");

  name = "New session";
  await emit("session_info_changed");
  name = " ";
  await emit("session_info_changed");
  assert.equal(last().tokens.session_name, "New thread");

  await emit("session_shutdown");
  assert.equal(last().tokens.session_name, null);
  for (const request of requests) {
    assert.equal(request.method, "pane.report_metadata");
    assert.deepEqual(Object.keys(request.params.tokens), ["session_name"]);
    assert.equal(Object.hasOwn(request.params, "title"), false);
    assert.equal(Object.hasOwn(request.params, "clear_title"), false);
  }
  const count = requests.length;
  await emit("session_info_changed");
  assert.equal(requests.length, count);
});
