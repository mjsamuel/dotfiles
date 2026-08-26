import net from "node:net";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const socketPath = process.env.HERDR_SOCKET_PATH;
const socketEndpoint =
	process.platform === "win32" && socketPath ? `\\\\.\\pipe\\${socketPath}` : socketPath;
const paneId = process.env.HERDR_PANE_ID;
const source = "pi-activity";
const integrationSource = "herdr:pi";
const maxSummaryLength = 120;

let reportSeq = Date.now() * 1000;

function nextReportSeq(): number {
	reportSeq += 1;
	return reportSeq;
}

function cleanText(value: unknown): string | undefined {
	if (typeof value !== "string") return undefined;

	const cleaned = value.replace(/\*\*/g, "").replace(/\s+/g, " ").trim();
	if (!cleaned) return undefined;
	if (cleaned.length <= maxSummaryLength) return cleaned;

	return `${cleaned.slice(0, maxSummaryLength - 1).trimEnd()}…`;
}

function sendRequest(request: unknown): Promise<void> {
	if (process.env.HERDR_ENV !== "1" || !socketEndpoint || !paneId) {
		return Promise.resolve();
	}

	return new Promise((resolve) => {
		let finished = false;
		const socket = net.createConnection(socketEndpoint);
		const finish = () => {
			if (finished) return;
			finished = true;
			socket.destroy();
			resolve();
		};

		socket.on("error", finish);
		socket.on("connect", () => socket.write(`${JSON.stringify(request)}\n`));
		socket.on("data", finish);
		socket.on("end", finish);

		const timeout = setTimeout(finish, 750);
		timeout.unref?.();
	});
}

function reportSummary(summary?: string): Promise<void> {
	return sendRequest({
		id: `${source}:${Date.now()}:${Math.random().toString(36).slice(2)}`,
		method: "pane.report_metadata",
		params: {
			pane_id: paneId,
			source,
			applies_to_source: integrationSource,
			seq: nextReportSeq(),
			tokens: { summary: summary ?? null },
		},
	});
}

/** Reports Pi's current reasoning, task, and final response to Herdr's Agent panel. */
export default function (pi: ExtensionAPI) {
	let active = false;
	let taskSummary: string | undefined;
	let pendingTaskSummary: string | undefined;
	let thinkingSummary: string | undefined;
	let candidateResponseSummary: string | undefined;
	let responseSummary: string | undefined;

	function publishCurrentActivity(): void {
		void reportSummary(thinkingSummary ?? responseSummary ?? taskSummary);
	}

	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		active = true;
		void reportSummary("Ready");
	});

	pi.on("input", (event) => {
		if (!active) return;

		const nextSummary = cleanText(event.text);
		if (event.streamingBehavior === "followUp") {
			pendingTaskSummary = nextSummary;
			return;
		}

		taskSummary = nextSummary;
		thinkingSummary = undefined;
		candidateResponseSummary = undefined;
		responseSummary = undefined;
		publishCurrentActivity();
	});

	pi.on("before_agent_start", (event) => {
		if (!active) return;

		// Covers queued follow-ups and prompts injected by extensions.
		taskSummary = pendingTaskSummary ?? taskSummary ?? cleanText(event.prompt);
		pendingTaskSummary = undefined;
		thinkingSummary = undefined;
		candidateResponseSummary = undefined;
		responseSummary = undefined;
		publishCurrentActivity();
	});

	pi.on("message_update", (event) => {
		if (!active) return;

		const update = event.assistantMessageEvent;
		switch (update.type) {
			case "thinking_end":
				thinkingSummary = cleanText(update.content);
				candidateResponseSummary = undefined;
				publishCurrentActivity();
				break;
			case "text_end":
				candidateResponseSummary = cleanText(update.content);
				break;
		}
	});

	pi.on("turn_end", (event) => {
		if (!active || event.toolResults.length > 0) return;

		responseSummary = candidateResponseSummary;
		thinkingSummary = undefined;
		publishCurrentActivity();
	});

	pi.on("agent_settled", () => {
		if (!active) return;

		publishCurrentActivity();
	});

	pi.on("session_shutdown", () => {
		if (!active) return;

		active = false;
		void reportSummary();
	});
}
