import {
  CustomEditor,
  type ExtensionAPI,
  type ExtensionContext,
  type KeybindingsManager,
} from "@earendil-works/pi-coding-agent";
import type { EditorTheme, TUI } from "@earendil-works/pi-tui";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

function formatTokens(count: number): string {
  if (count < 1_000) return count.toString();
  if (count < 10_000) return `${(count / 1_000).toFixed(1)}k`;
  if (count < 1_000_000) return `${Math.round(count / 1_000)}k`;
  if (count < 10_000_000) return `${(count / 1_000_000).toFixed(1)}M`;
  return `${Math.round(count / 1_000_000)}M`;
}

function sanitizeStatus(text: string): string {
  return text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim();
}

function formatCost(value: string): string {
  const parsed = Number(value.replace(/[$,]/g, ""));
  return Number.isFinite(parsed) ? `$${parsed.toFixed(2)}` : value;
}

function usageStats(ctx: ExtensionContext) {
  let input = 0;
  let output = 0;
  let cacheRead = 0;
  let cacheWrite = 0;
  let latestCacheHitRate: number | undefined;

  for (const entry of ctx.sessionManager.getEntries()) {
    let usage;
    if (entry.type === "message" && entry.message.role === "assistant") {
      usage = entry.message.usage;
      const promptTokens = usage.input + usage.cacheRead + usage.cacheWrite;
      latestCacheHitRate = promptTokens > 0 ? (usage.cacheRead / promptTokens) * 100 : undefined;
    } else if (entry.type === "message" && entry.message.role === "toolResult") {
      usage = entry.message.usage;
    } else if (entry.type === "branch_summary" || entry.type === "compaction") {
      usage = entry.usage;
    }

    if (!usage) continue;
    input += usage.input;
    output += usage.output;
    cacheRead += usage.cacheRead;
    cacheWrite += usage.cacheWrite;
  }

  return { input, output, cacheRead, cacheWrite, latestCacheHitRate };
}

function modelLabel(ctx: ExtensionContext): string {
  const model = ctx.model;
  if (!model) return "no-model";
  if (!model.reasoning) return model.id;

  return `${model.id} · ${ctx.thinkingLevel}`;
}

function thinkingColor(level: string) {
  switch (level) {
    case "minimal": return "thinkingMinimal" as const;
    case "low": return "thinkingLow" as const;
    case "medium": return "thinkingMedium" as const;
    case "high": return "thinkingHigh" as const;
    case "xhigh": return "thinkingXhigh" as const;
    case "max": return "thinkingMax" as const;
    default: return "thinkingOff" as const;
  }
}

export default function footer(pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    class FixedBorderEditor extends CustomEditor {
      constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
        super(tui, theme, keybindings);
      }

      render(width: number): string[] {
        // Pi updates this property when effort changes, so restore the muted
        // border immediately before each render.
        this.borderColor = (text) => ctx.ui.theme.fg("dim", text);
        const lines = super.render(width);
        const sessionName = ctx.sessionManager.getSessionName()?.trim();

        if (!sessionName || lines.length === 0 || width < 4) return lines;

        const name = truncateToWidth(sessionName, Math.max(0, width - 4), "");
        const label = ` ${name} `;
        const labelWidth = visibleWidth(label);
        const prefix = this.borderColor("─");
        const suffix = this.borderColor("─".repeat(Math.max(0, width - 1 - labelWidth)));
        lines[0] = prefix + this.borderColor(label) + suffix;
        return lines;
      }
    }

    ctx.ui.setEditorComponent((tui, theme, keybindings) => new FixedBorderEditor(tui, theme, keybindings));
    ctx.ui.setFooter((_tui, theme, footerData) => ({
      invalidate() {},
      render(width: number): string[] {
        const usage = usageStats(ctx);
        const statusEntries = Array.from(footerData.getExtensionStatuses().entries())
          .sort(([a], [b]) => a.localeCompare(b));
        const usageStatus = statusEntries.find(([key]) => key === "model-usage")?.[1];
        const costs = usageStatus?.match(/\$[\d,.]+/g);
        const cost = costs && costs.length >= 2
          ? `${formatCost(costs[0])}/${formatCost(costs[1])}`
          : undefined;
        const parts: string[] = [];

        if (usage.input) parts.push(`↑${formatTokens(usage.input)}`);
        if (usage.output) parts.push(`↓${formatTokens(usage.output)}`);
        if (usage.cacheRead) parts.push(`R${formatTokens(usage.cacheRead)}`);
        if (usage.cacheWrite) parts.push(`W${formatTokens(usage.cacheWrite)}`);
        if ((usage.cacheRead || usage.cacheWrite) && usage.latestCacheHitRate !== undefined) {
          parts.push(`CH${usage.latestCacheHitRate.toFixed(1)}%`);
        }
        if (cost) parts.push(cost);

        const context = ctx.getContextUsage();
        const contextWindow = context?.contextWindow ?? ctx.model?.contextWindow ?? 0;
        const contextPercent = context?.percent;
        const formattedPercent = contextPercent === null || contextPercent === undefined
          ? "?"
          : `${contextPercent.toFixed(1)}%`;
        const contextText = `${formattedPercent}/${formatTokens(contextWindow)} (auto)`;
        const coloredContext = contextPercent !== null && contextPercent !== undefined && contextPercent > 90
          ? theme.fg("error", contextText)
          : contextPercent !== null && contextPercent !== undefined && contextPercent > 70
            ? theme.fg("warning", contextText)
            : contextText;
        parts.push(coloredContext);

        const left = modelLabel(ctx);
        const styledLeft = ctx.model
          ? theme.fg("text", `${ctx.model.id}${ctx.model.reasoning ? " · " : ""}`)
            + (ctx.model.reasoning
              ? theme.fg(thinkingColor(ctx.thinkingLevel), ctx.thinkingLevel)
              : "")
          : theme.fg("text", left);
        const right = parts.join(" · ");
        const minimumGap = 2;
        const availableRight = Math.max(0, width - visibleWidth(left) - minimumGap);
        const visibleRight = truncateToWidth(right, availableRight, "");
        const padding = " ".repeat(Math.max(0, width - visibleWidth(left) - visibleWidth(visibleRight)));
        const lines = [styledLeft + padding + theme.fg("dim", visibleRight)];

        const remainingStatuses = statusEntries
          .filter(([key]) => key !== "model-usage")
          .map(([, text]) => sanitizeStatus(text));
        if (remainingStatuses.length > 0) {
          lines.push(truncateToWidth(remainingStatuses.join(" "), width, theme.fg("dim", "...")));
        }

        return lines;
      },
    }));
  });
}
