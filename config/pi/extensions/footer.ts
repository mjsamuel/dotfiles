import {
  CustomEditor,
  type ExtensionAPI,
  type ExtensionContext,
  type KeybindingsManager,
  type Theme,
  type ThemeColor,
} from "@earendil-works/pi-coding-agent";
import type { EditorTheme, TUI } from "@earendil-works/pi-tui";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type ModelColor = { pattern: RegExp; dark: string; light: string; fallback: ThemeColor };

const MODEL_COLORS: ModelColor[] = [
  { pattern: /astra/i, dark: "#3987e5", light: "#2a78d6", fallback: "accent" },
  { pattern: /luna/i, dark: "#ffffff", light: "#57606a", fallback: "text" },
  { pattern: /sol/i, dark: "#e3b341", light: "#9a6700", fallback: "warning" },
  { pattern: /terra/i, dark: "#3fb950", light: "#1a7f37", fallback: "success" },
  { pattern: /fable-?5/i, dark: "#d95926", light: "#e9561c", fallback: "syntaxNumber" },
  { pattern: /grok/i, dark: "#9198a1", light: "#59636e", fallback: "dim" },
];

function fgHex(hex: string, text: string): string {
  const r = Number.parseInt(hex.slice(1, 3), 16);
  const g = Number.parseInt(hex.slice(3, 5), 16);
  const b = Number.parseInt(hex.slice(5, 7), 16);
  return `\x1b[38;2;${r};${g};${b}m${text}\x1b[39m`;
}

function isLightBackground(theme: Theme): boolean {
  const match = /38;2;(\d+);(\d+);(\d+)/.exec(theme.getFgAnsi("text"));
  if (!match) return false;
  const [r, g, b] = [Number(match[1]), Number(match[2]), Number(match[3])];
  return (0.299 * r + 0.587 * g + 0.114 * b) / 255 < 0.5;
}

function styledModel(modelId: string, theme: Theme): string {
  const color = MODEL_COLORS.find(({ pattern }) => pattern.test(modelId));
  if (!color) return theme.fg("text", modelId);
  if (theme.getColorMode() !== "truecolor") return theme.fg(color.fallback, modelId);
  return fgHex(isLightBackground(theme) ? color.light : color.dark, modelId);
}

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
          ? styledModel(ctx.model.id, theme)
            + (ctx.model.reasoning ? theme.fg("text", ` · ${ctx.thinkingLevel ?? "off"}`) : "")
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
