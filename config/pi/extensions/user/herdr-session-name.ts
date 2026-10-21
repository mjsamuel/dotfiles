import net from "node:net";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const socketPath = process.env.HERDR_SOCKET_PATH;
const socketEndpoint =
	process.platform === "win32" && socketPath ? `\\\\.\\pipe\\${socketPath}` : socketPath;
const paneId = process.env.HERDR_PANE_ID;
const source = "pi-activity";
const integrationSource = "herdr:pi";

let reportSeq = Date.now() * 1000;

function sendRequest(request: unknown): Promise<void> {
	if (process.env.HERDR_ENV !== "1" || !socketEndpoint || !paneId) {
		return Promise.resolve();
	}

	return new Promise((resolve) => {
		let finished = false;
		let timeout: ReturnType<typeof setTimeout> | undefined;
		const socket = net.createConnection(socketEndpoint);
		const finish = () => {
			if (finished) return;
			finished = true;
			clearTimeout(timeout);
			socket.destroy();
			resolve();
		};

		socket.on("error", finish);
		socket.on("connect", () => socket.write(`${JSON.stringify(request)}\n`));
		socket.on("data", finish);
		socket.on("end", finish);

		timeout = setTimeout(finish, 750);
		timeout.unref?.();
	});
}

function reportSessionName(name?: string): Promise<void> {
	return sendRequest({
		id: `${source}:${Date.now()}:${Math.random().toString(36).slice(2)}`,
		method: "pane.report_metadata",
		params: {
			pane_id: paneId,
			source,
			applies_to_source: integrationSource,
			seq: ++reportSeq,
			tokens: { session_name: name ?? null },
		},
	});
}

/** Reports Pi's session name to Herdr's Agent sidebar. */
export default function (pi: ExtensionAPI) {
	let active = false;

	function publishSessionName(): void {
		const name = pi.getSessionName()?.trim() || "New thread";
		void reportSessionName(name.charAt(0).toUpperCase() + name.slice(1));
	}

	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		active = true;
		publishSessionName();
	});

	pi.on("session_info_changed", () => {
		if (active) publishSessionName();
	});

	pi.on("session_shutdown", () => {
		if (!active) return;

		active = false;
		void reportSessionName();
	});
}
