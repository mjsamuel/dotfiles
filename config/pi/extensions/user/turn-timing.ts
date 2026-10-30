import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";

interface TurnTiming {
  durationMs: number;
  completedAt: number;
  aborted: boolean;
}

export function formatDuration(durationMs: number): string {
  const seconds = Math.max(1, Math.round(durationMs / 1_000));
  if (seconds < 60) return `${seconds}s`;
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ${seconds % 60}s`;
  return `${Math.floor(minutes / 60)}h ${minutes % 60}m ${seconds % 60}s`;
}

export default function turnTiming(pi: ExtensionAPI) {
  let startedAt: number | undefined;

  pi.registerEntryRenderer<TurnTiming>("turn-timing", (entry, _options, theme) => {
    if (!entry.data) return;
    const { durationMs, completedAt, aborted } = entry.data;
    const time = new Date(completedAt).toLocaleTimeString("en-US", {
      hour: "numeric",
      minute: "2-digit",
    });
    return new Text(theme.fg("muted", `Worked for ${formatDuration(durationMs)} · ${aborted ? "stopped" : "done"} ${time}`), pi.getSettings().outputPad ?? 1, 0);
  });

  pi.on("before_agent_start", (_event, ctx) => {
    if (ctx.mode === "tui") startedAt ??= performance.now();
  });

  pi.on("agent_settled", (event) => {
    if (startedAt === undefined) return;
    const durationMs = performance.now() - startedAt;
    startedAt = undefined;
    pi.appendEntry<TurnTiming>("turn-timing", {
      durationMs,
      completedAt: Date.now(),
      aborted: event.aborted,
    });
  });

  pi.on("session_shutdown", () => {
    startedAt = undefined;
  });
}
