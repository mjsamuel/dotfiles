import type { ExtensionAPI, ExtensionContext, Theme, ThemeColor } from "@earendil-works/pi-coding-agent";
import {
  Key,
  matchesKey,
  truncateToWidth,
  visibleWidth,
  type Component,
  type TUI,
} from "@earendil-works/pi-tui";
import { createHash } from "node:crypto";
import { readFile, readdir } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";

const DAY = 86_400_000;

// A fixed, colorblind-checked categorical palette for chart series — same hue
// order in both variants, values chosen for contrast against a dark vs a light
// terminal background respectively. This is a different job than the four-ish
// *state* colors (accent/success/error/warning) a theme is actually designed
// around, so it's rendered directly as truecolor rather than through a theme
// role: see CHART_COLORS_FALLBACK below for terminals that can't do truecolor.
//
// The light variant is darkened from the generic reference palette (tuned
// against a near-white #fcfcfb surface) to clear 3:1 contrast against
// rose-pine-dawn's actual cream background (#faf4ed) — checked with the
// dataviz skill's validator: orange/aqua/yellow/magenta all landed under 3:1
// (yellow as low as 1.98:1) against the real, warmer surface. Same hue and
// saturation, just darker; re-run the validator against your own theme's
// surface if you retheme this.
const SERIES_HEX_DARK = ["#3987e5", "#d95926", "#199e70", "#c98500", "#d55181", "#008300", "#9085e9"];
const SERIES_HEX_LIGHT = ["#2a78d6", "#e9561c", "#18996b", "#b67b00", "#e15389", "#008300", "#4a3aa7"];

// Fallback for 256-color terminals, where an exact hex can't be rendered
// faithfully anyway: candidate theme roles, roughly ordered by how likely a
// theme is to give them genuinely distinct colors (state colors first, then
// syntax colors, which by convention span a wide range for readability, then
// more decorative roles last). Many themes alias several of these to the same
// underlying color (e.g. rose-pine's mdLink/success/toolDiffAdded/thinkingMedium
// are all "foam"), so this list is deliberately longer than the number of
// series we expect to render — rebuildColors() below dedupes by resolved
// color, not by role name, and only as many roles as are actually distinct
// in the active theme get used.
const CHART_COLORS_FALLBACK: ThemeColor[] = [
  "accent",
  "success",
  "error",
  "warning",
  "syntaxFunction",
  "syntaxKeyword",
  "syntaxType",
  "syntaxNumber",
  "syntaxString",
  "mdLink",
  "toolDiffAdded",
  "toolDiffRemoved",
  "thinkingHigh",
  "thinkingMedium",
];
const PARTIAL_BLOCKS = "▁▂▃▄▅▆▇█";
const MOUSE_ENABLE = "\x1b[?1000h\x1b[?1006h";
const MOUSE_DISABLE = "\x1b[?1006l\x1b[?1000l";
const SGR_MOUSE = /^\x1b\[<(\d+);(\d+);(\d+)([Mm])$/;

/** Wrap text in a 24-bit foreground color, resetting only the foreground. */
function fgHex(hex: string, text: string): string {
  const r = Number.parseInt(hex.slice(1, 3), 16);
  const g = Number.parseInt(hex.slice(3, 5), 16);
  const b = Number.parseInt(hex.slice(5, 7), 16);
  return `\x1b[38;2;${r};${g};${b}m${text}\x1b[39m`;
}

type Paint = (text: string) => string;
type Granularity = "daily" | "weekly";
type Grouping = "model" | "provider";
type Action = "daily" | "weekly" | "group" | "prev" | "next" | "today" | "refresh" | "close";

interface ClickRegion {
  row: number;
  x1: number;
  x2: number;
  action: Action;
}

interface Segment {
  text: string;
  action?: Action;
}

interface UsageRecord {
  timestamp: number;
  provider: string;
  model: string;
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
  cost: number;
}

interface Bucket {
  start: number;
  end: number;
  label: string;
  values: Map<string, number>;
  total: number;
}

interface GroupTotal {
  key: string;
  cost: number;
  priorCost: number;
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
}

function agentDir(): string {
  return process.env.PI_CODING_AGENT_DIR ?? join(homedir(), ".pi", "agent");
}

function sessionRoot(): string {
  return process.env.PI_CODING_AGENT_SESSION_DIR ?? join(agentDir(), "sessions");
}

async function findSessionFiles(root: string): Promise<string[]> {
  const files: string[] = [];
  async function walk(directory: string): Promise<void> {
    let entries;
    try {
      entries = await readdir(directory, { withFileTypes: true });
    } catch {
      return;
    }
    await Promise.all(
      entries.map(async (entry) => {
        const path = join(directory, entry.name);
        if (entry.isDirectory()) await walk(path);
        else if (entry.isFile() && entry.name.endsWith(".jsonl")) files.push(path);
      }),
    );
  }
  await walk(root);
  return files;
}

function finite(value: unknown): number {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}

function usageRecord(
  usage: any,
  timestamp: number,
  provider: string | undefined,
  model: string | undefined,
): UsageRecord | undefined {
  if (!usage || typeof usage !== "object") return undefined;
  const cost = finite(usage.cost?.total);
  const input = finite(usage.input);
  const output = finite(usage.output);
  const cacheRead = finite(usage.cacheRead);
  const cacheWrite = finite(usage.cacheWrite);
  if (cost === 0 && input === 0 && output === 0 && cacheRead === 0 && cacheWrite === 0) return undefined;
  return {
    timestamp,
    provider: provider || "unknown",
    model: model || "unknown",
    input,
    output,
    cacheRead,
    cacheWrite,
    cost,
  };
}

async function loadUsage(): Promise<UsageRecord[]> {
  const files = await findSessionFiles(sessionRoot());
  const seen = new Set<string>();
  const records: UsageRecord[] = [];

  await Promise.all(
    files.map(async (path) => {
      let text: string;
      try {
        text = await readFile(path, "utf8");
      } catch {
        return;
      }

      let selectedProvider = "unknown";
      let selectedModel = "unknown";
      for (const line of text.split("\n")) {
        if (!line.trim()) continue;
        let entry: any;
        try {
          entry = JSON.parse(line);
        } catch {
          continue;
        }

        if (entry.type === "model_change") {
          selectedProvider = entry.provider || selectedProvider;
          selectedModel = entry.modelId || selectedModel;
          continue;
        }

        const timestamp =
          finite(entry.message?.timestamp) || Date.parse(entry.timestamp) || Date.now();
        let record: UsageRecord | undefined;
        let identity: string | undefined;

        if (entry.type === "message" && entry.message?.role === "assistant") {
          const message = entry.message;
          record = usageRecord(message.usage, timestamp, message.provider, message.model);
          selectedProvider = message.provider || selectedProvider;
          selectedModel = message.model || selectedModel;
          identity = message.responseId ||
            `${message.timestamp}:${message.provider}:${message.model}:${message.usage?.cost?.total}:${entry.id}`;
        } else if (entry.type === "message" && entry.message?.role === "toolResult" && entry.message.usage) {
          record = usageRecord(entry.message.usage, timestamp, selectedProvider, selectedModel);
          identity = `tool:${entry.message.toolCallId || entry.id}:${entry.message.timestamp || entry.timestamp}`;
        } else if ((entry.type === "compaction" || entry.type === "branch_summary") && entry.usage) {
          record = usageRecord(entry.usage, timestamp, selectedProvider, selectedModel);
          identity = `${entry.type}:${entry.id}:${entry.timestamp}`;
        }

        if (!record || !identity) continue;
        // Forked sessions copy prior messages. Deduplicate copied API responses globally.
        const fingerprint = createHash("sha1").update(identity).digest("hex");
        if (seen.has(fingerprint)) continue;
        seen.add(fingerprint);
        records.push(record);
      }
    }),
  );

  return records.sort((a, b) => a.timestamp - b.timestamp);
}

function utcDayStart(timestamp: number): number {
  const date = new Date(timestamp);
  return Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate());
}

function utcWeekStart(timestamp: number): number {
  const day = utcDayStart(timestamp);
  const weekday = new Date(day).getUTCDay();
  return day - ((weekday + 6) % 7) * DAY;
}

function formatDate(timestamp: number): string {
  return new Date(timestamp).toLocaleDateString("en", {
    timeZone: "UTC",
    month: "short",
    day: "numeric",
  });
}

function formatShortDate(timestamp: number): string {
  const date = new Date(timestamp);
  return `${String(date.getUTCMonth() + 1).padStart(2, "0")}-${String(date.getUTCDate()).padStart(2, "0")}`;
}

// 1/2/2.5/5/10 leaves a gap between 2.5 and 5 where a bar just over 2.5×base
// (e.g. 26 rounding to 50) fills only half the chart. This ladder caps the
// worst case at 20% headroom instead of 50%.
const NICE_STEPS = [1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10];

/** Round up to a "nice" chart ceiling. */
function niceCeil(value: number): number {
  if (value <= 0) return 1;
  const exponent = Math.floor(Math.log10(value));
  const base = 10 ** exponent;
  const mantissa = value / base;
  const nice = NICE_STEPS.find((step) => mantissa <= step) ?? 10;
  return nice * base;
}

function formatAxisMoney(value: number): string {
  return value >= 1 ? `$${Number(value.toFixed(2))}` : formatMoney(value);
}

function formatMoney(value: number): string {
  if (value >= 1000) return `$${value.toLocaleString("en", { maximumFractionDigits: 0 })}`;
  if (value >= 10) return `$${value.toFixed(2)}`;
  if (value >= 0.01) return `$${value.toFixed(3)}`;
  return `$${value.toFixed(4)}`;
}

function formatTokens(value: number): string {
  if (value >= 1_000_000) return `${(value / 1_000_000).toFixed(1)}m`;
  if (value >= 1_000) return `${(value / 1_000).toFixed(1)}k`;
  return String(value);
}

function padRight(text: string, width: number): string {
  const clipped = truncateToWidth(text, Math.max(0, width), "");
  return clipped + " ".repeat(Math.max(0, width - visibleWidth(clipped)));
}

function padLeft(text: string, width: number): string {
  const clipped = truncateToWidth(text, Math.max(0, width), "");
  return " ".repeat(Math.max(0, width - visibleWidth(clipped))) + clipped;
}

class UsageDashboard implements Component {
  private records: UsageRecord[];
  private granularity: Granularity = "daily";
  private grouping: Grouping = "model";
  private offset = 0;
  private loading = false;
  private error: string | undefined;
  private regions: ClickRegion[] = [];
  private colorMap = new Map<string, Paint>();
  private readonly mouseCapable: boolean;
  private disposed = false;

  constructor(
    records: UsageRecord[],
    private readonly tui: TUI,
    private readonly theme: Theme,
    private readonly done: () => void,
  ) {
    this.records = records;
    // The alt-screen TUI owns the mouse (selection/scrolling) and never forwards
    // clicks to components, so only take over mouse reporting on the main screen.
    const ctor = (this.tui as unknown as { constructor?: { name?: string } }).constructor?.name ?? "";
    this.mouseCapable = !ctor.includes("AltScreen");
    if (this.mouseCapable) this.tui.terminal.write(MOUSE_ENABLE);
    this.rebuildColors();
  }

  /**
   * Canonical colors: assign the palette by all-time spend rank so a model
   * keeps its color while navigating periods, instead of reshuffling per view.
   *
   * Truecolor terminals get the fixed SERIES_HEX palette, picked for the light
   * or dark variant by isLightBackground(). 256-color terminals can't render
   * an exact hex faithfully, so they fall back to theme roles instead — but
   * role names alone don't guarantee distinct colors (themes are free to alias
   * several roles to the same underlying color; rose-pine's bundled theme
   * gives only 6 distinct hues across the 14 fallback role names), so that
   * path resolves each candidate through the active theme and dedupes by the
   * rendered ANSI sequence. Either way, whatever doesn't fit in the palette's
   * budget of distinct colors falls back to a shared "dim" bucket rather than
   * silently reusing another series' color.
   */
  private rebuildColors(): void {
    const totals = new Map<string, number>();
    for (const record of this.records) {
      const key = this.groupKey(record);
      totals.set(key, (totals.get(key) ?? 0) + record.cost);
    }
    const keys = [...totals.entries()].sort((a, b) => b[1] - a[1]).map(([key]) => key);
    const dim: Paint = (text) => this.theme.fg("dim", text);

    this.colorMap = new Map();

    if (this.theme.getColorMode() === "truecolor") {
      const palette = this.isLightBackground() ? SERIES_HEX_LIGHT : SERIES_HEX_DARK;
      keys.forEach((key, index) => {
        const hex = palette[index];
        this.colorMap.set(key, hex ? (text) => fgHex(hex, text) : dim);
      });
      return;
    }

    const seenAnsi = new Set<string>();
    const distinctColors: ThemeColor[] = [];
    for (const color of CHART_COLORS_FALLBACK) {
      const ansi = this.theme.getFgAnsi(color);
      if (seenAnsi.has(ansi)) continue;
      seenAnsi.add(ansi);
      distinctColors.push(color);
    }
    keys.forEach((key, index) => {
      const role = distinctColors[index];
      this.colorMap.set(key, role ? (text) => this.theme.fg(role, text) : dim);
    });
  }

  /**
   * No public API exposes a theme's light/dark polarity directly. A theme's
   * own text color has to contrast its background, so infer it from that:
   * dark text implies a light surface, light text implies a dark one.
   */
  private isLightBackground(): boolean {
    const match = /38;2;(\d+);(\d+);(\d+)/.exec(this.theme.getFgAnsi("text"));
    if (!match) return false;
    const [r, g, b] = [Number(match[1]), Number(match[2]), Number(match[3])];
    const textLuminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    return textLuminance < 0.5;
  }

  dispose(): void {
    if (this.disposed) return;
    this.disposed = true;
    if (this.mouseCapable) this.tui.terminal.write(MOUSE_DISABLE);
  }

  invalidate(): void {}

  private groupKey(record: UsageRecord): string {
    return this.grouping === "provider" ? record.provider : `${record.provider}/${record.model}`;
  }

  private bucketCount(width: number): number {
    const labelWidth = width >= 70 ? 9 : 7;
    const availableWidth = Math.max(1, width - labelWidth);
    return Math.max(1, Math.min(7, Math.floor(availableWidth / 9)));
  }

  private period(count: number): { start: number; end: number; step: number; count: number } {
    const step = this.granularity === "daily" ? DAY : 7 * DAY;
    const current = this.granularity === "daily" ? utcDayStart(Date.now()) : utcWeekStart(Date.now());
    const end = current + step - this.offset * count * step;
    return { start: end - count * step, end, step, count };
  }

  private data(count: number): { buckets: Bucket[]; groups: GroupTotal[]; total: number } {
    const { start, end, step } = this.period(count);
    const buckets: Bucket[] = Array.from({ length: count }, (_, index) => {
      const bucketStart = start + index * step;
      return {
        start: bucketStart,
        end: bucketStart + step,
        label: formatShortDate(bucketStart),
        values: new Map<string, number>(),
        total: 0,
      };
    });
    const totals = new Map<string, GroupTotal>();

    for (const record of this.records) {
      const key = this.groupKey(record);
      if (record.timestamp >= start && record.timestamp < end) {
        const index = Math.floor((record.timestamp - start) / step);
        const bucket = buckets[index];
        if (bucket) {
          bucket.values.set(key, (bucket.values.get(key) ?? 0) + record.cost);
          bucket.total += record.cost;
        }
        const total = totals.get(key) ?? {
          key,
          cost: 0,
          priorCost: 0,
          input: 0,
          output: 0,
          cacheRead: 0,
          cacheWrite: 0,
        };
        total.cost += record.cost;
        total.input += record.input;
        total.output += record.output;
        total.cacheRead += record.cacheRead;
        total.cacheWrite += record.cacheWrite;
        totals.set(key, total);
      } else if (record.timestamp >= start - (end - start) && record.timestamp < start) {
        const total = totals.get(key) ?? {
          key,
          cost: 0,
          priorCost: 0,
          input: 0,
          output: 0,
          cacheRead: 0,
          cacheWrite: 0,
        };
        total.priorCost += record.cost;
        totals.set(key, total);
      }
    }

    const groups = [...totals.values()].filter((group) => group.cost > 0).sort((a, b) => b.cost - a.cost);
    return { buckets, groups, total: groups.reduce((sum, group) => sum + group.cost, 0) };
  }

  private paint(key: string, text: string): string {
    const paint = this.colorMap.get(key) ?? ((t: string) => this.theme.fg("dim", t));
    return paint(text);
  }

  private groupAt(bucket: Bucket, groups: GroupTotal[], value: number): string | undefined {
    let cumulative = 0;
    for (const group of [...groups].reverse()) {
      cumulative += bucket.values.get(group.key) ?? 0;
      if (value <= cumulative) return group.key;
    }
    return undefined;
  }

  private renderChart(width: number, buckets: Bucket[], groups: GroupTotal[], chartHeight: number): string[] {
    const labelWidth = width >= 70 ? 9 : 7;
    const plotWidth = Math.max(1, width - labelWidth);
    const slotWidth = Math.max(1, Math.floor(plotWidth / buckets.length));
    const barWidth = Math.max(1, slotWidth - (slotWidth > 1 ? 1 : 0));
    const max = Math.max(...buckets.map((bucket) => bucket.total), 0);
    const niceMax = niceCeil(max);
    const lines: string[] = [];

    // Dotted horizontal gridlines at intermediate y-axis ticks, drawn behind bars.
    const divisions = chartHeight >= 8 ? 4 : 2;
    const gridRows = new Map<number, number>(); // rowFromBottom -> tick value
    for (let k = 1; k < divisions; k++) {
      const rowFromBottom = Math.round((k / divisions) * chartHeight) - 1;
      if (rowFromBottom > 0 && rowFromBottom < chartHeight - 1) {
        gridRows.set(rowFromBottom, (niceMax * k) / divisions);
      }
    }

    // Pass 1: cell ownership per bucket, indexed by row-from-bottom.
    const columns = buckets.map((bucket) => {
      const barRows = (bucket.total / niceMax) * chartHeight;
      const cells: { fill: number; key?: string }[] = [];
      for (let r = 0; r < chartHeight; r++) {
        const fill = Math.max(0, Math.min(1, barRows - r));
        if (fill <= 0.01) {
          cells.push({ fill: 0 });
          continue;
        }
        // Full cells sample the stack at this height; the fractional top cell
        // takes the color of the topmost segment.
        const sample = fill >= 0.99
          ? ((r + 0.5) / chartHeight) * niceMax
          : Math.max(0, bucket.total - 1e-9);
        cells.push({ fill, key: this.groupAt(bucket, groups, sample) });
      }
      return cells;
    });

    // Pass 2: in-bar names, centered on segment runs of ≥2 full rows that fit.
    const inBarLabels = columns.map((cells) => {
      const labels = new Map<number, string>();
      if (barWidth < 6) return labels;
      let runStart = -1;
      let runKey: string | undefined;
      const flush = (end: number) => {
        const run = end - runStart;
        if (runKey === undefined || runStart < 0 || run < 2) return;
        const name = this.grouping === "model"
          ? runKey.split("/").slice(1).join("/") || runKey
          : runKey;
        if (visibleWidth(name) <= barWidth - 2) {
          labels.set(runStart + Math.floor((run - 1) / 2), name);
        }
      };
      for (let r = 0; r < chartHeight; r++) {
        const cell = cells[r]!;
        const key = cell.fill >= 0.99 ? cell.key : undefined;
        if (key !== runKey) {
          flush(r);
          runStart = r;
          runKey = key;
        }
      }
      flush(chartHeight);
      return labels;
    });

    for (let row = 0; row < chartHeight; row++) {
      const rowFromBottom = chartHeight - 1 - row;
      const gridValue = gridRows.get(rowFromBottom);
      const yLabel = row === 0
        ? padLeft(formatAxisMoney(niceMax), labelWidth - 2) + " │"
        : gridValue !== undefined
          ? this.theme.fg("dim", padLeft(formatAxisMoney(gridValue), labelWidth - 2)) + " │"
          : " ".repeat(labelWidth - 1) + "│";
      const blank = (count: number) => count <= 0
        ? ""
        : gridValue !== undefined
          ? this.theme.fg("dim", "┄".repeat(count))
          : " ".repeat(count);
      let plot = "";
      for (let index = 0; index < buckets.length; index++) {
        const cell = columns[index]![rowFromBottom]!;
        if (cell.fill <= 0.01 || !cell.key) {
          plot += blank(barWidth);
        } else {
          const name = inBarLabels[index]!.get(rowFromBottom);
          if (name) {
            // Reverse video cuts the name out of the bar in the segment color.
            const pad = barWidth - visibleWidth(name);
            const left = Math.floor(pad / 2);
            plot += this.paint(
              cell.key,
              `${"█".repeat(left)}\x1b[7m${name}\x1b[27m${"█".repeat(pad - left)}`,
            );
          } else {
            const glyph = cell.fill >= 0.99
              ? "█"
              : PARTIAL_BLOCKS[Math.max(0, Math.min(7, Math.round(cell.fill * 8) - 1))]!;
            plot += this.paint(cell.key, glyph.repeat(barWidth));
          }
        }
        plot += blank(Math.max(0, slotWidth - barWidth));
      }
      plot += blank(plotWidth - slotWidth * buckets.length);
      lines.push(truncateToWidth(yLabel + plot, width, ""));
    }

    const axis = this.theme.fg("dim", padLeft("$0", labelWidth - 2)) + " └" + "─".repeat(Math.max(0, width - labelWidth));
    lines.push(truncateToWidth(axis, width, ""));
    let labels = " ".repeat(labelWidth);
    for (const bucket of buckets) labels += padRight(bucket.label, slotWidth);
    lines.push(truncateToWidth(this.theme.fg("dim", labels), width, ""));
    return lines;
  }

  private renderLegend(width: number, groups: GroupTotal[]): string[] {
    const lines: string[] = [];
    let line = "";
    for (const group of groups) {
      const item = `${this.paint(group.key, "●")} ${group.key}  `;
      if (line && visibleWidth(line + item) > width) {
        lines.push(truncateToWidth(line, width, ""));
        line = "";
      }
      line += item;
    }
    if (line) lines.push(truncateToWidth(line, width, ""));
    return lines.slice(0, 2);
  }

  private changeText(group: GroupTotal): string {
    if (group.priorCost === 0) return group.cost === 0 ? "—" : "new";
    const percent = ((group.cost - group.priorCost) / group.priorCost) * 100;
    const sign = percent > 0 ? "+" : "";
    return `${sign}${percent.toFixed(1)}%`;
  }

  /** Append one line built from segments, recording click regions for actionable ones. */
  private pushRow(lines: string[], width: number, segments: Segment[]): void {
    const row = lines.length;
    let col = 0;
    let line = "";
    for (const segment of segments) {
      const segmentWidth = visibleWidth(segment.text);
      if (segment.action && col < width) {
        this.regions.push({ row, x1: col, x2: Math.min(width, col + segmentWidth), action: segment.action });
      }
      line += segment.text;
      col += segmentWidth;
    }
    lines.push(truncateToWidth(line, width, ""));
  }

  render(width: number): string[] {
    width = Math.max(1, width);
    const height = this.tui.terminal.rows;
    const count = this.bucketCount(width);
    const { start, end } = this.period(count);
    const { buckets, groups, total } = this.data(count);
    const legendLines = this.renderLegend(width, groups);
    // Chart fills whatever the fixed chrome (header, legend, table, hints) leaves over.
    const tableRows = Math.min(groups.length, Math.max(4, Math.floor(height / 4)));
    const statusLines = (groups.length === 0 ? 1 : 0) + (this.loading || this.error ? 1 : 0);
    const overhead =
      2 + // header + period rows
      1 + // blank
      2 + // chart axis + x labels
      legendLines.length +
      1 + // blank
      1 + // table header
      tableRows +
      statusLines +
      1; // hint row
    const chartHeight = Math.max(4, height - overhead);
    const lines: string[] = [];
    this.regions = [];
    const tab = (name: string, selected: boolean) => selected
      ? this.theme.bg("selectedBg", this.theme.bold(` ${name} `))
      : this.theme.fg("muted", ` ${name} `);

    // Header: title, granularity tabs, group toggle, close button (right-aligned).
    const headerSegments: Segment[] = [
      { text: this.theme.bold("Model usage & cost") },
      { text: "  " },
      { text: tab("Daily", this.granularity === "daily"), action: "daily" },
      { text: tab("Weekly", this.granularity === "weekly"), action: "weekly" },
      { text: "  " },
      {
        text: this.theme.fg("dim", "Group: ") + this.grouping + this.theme.fg("dim", " ⇆"),
        action: "group",
      },
    ];
    const closeText = this.theme.fg("dim", "✕ close");
    const headerWidth = headerSegments.reduce((sum, segment) => sum + visibleWidth(segment.text), 0);
    const closePad = width - headerWidth - visibleWidth(closeText);
    if (closePad > 1) {
      headerSegments.push({ text: " ".repeat(closePad) }, { text: closeText, action: "close" });
    }
    this.pushRow(lines, width, headerSegments);

    // Period line: ‹ › navigate, click date range → jump back to latest.
    const periodSegments: Segment[] = [
      { text: this.theme.fg("muted", "‹ "), action: "prev" },
      {
        text: `${this.theme.fg("accent", `${formatDate(start)} – ${formatDate(end - 1)}`)} ${this.theme.fg("dim", "(UTC)")}`,
      },
      { text: this.theme.fg("muted", " ›"), action: "next" },
      { text: `  ${this.theme.bold(formatMoney(total))}` },
    ];
    if (this.offset > 0) {
      periodSegments.push({ text: this.theme.fg("dim", "  · latest (t)"), action: "today" });
    }
    this.pushRow(lines, width, periodSegments);
    lines.push("");
    lines.push(...this.renderChart(width, buckets, groups, chartHeight));
    lines.push(...legendLines);
    lines.push("");

    if (width >= 90) {
      const modelWidth = Math.max(18, width - 58);
      const header = `${padRight(this.grouping === "model" ? "Model" : "Provider", modelWidth)} ${padLeft("Spend", 11)} ${padLeft("% total", 9)} ${padLeft("vs prior", 10)} ${padLeft("Input", 7)} ${padLeft("Output", 7)}`;
      lines.push(this.theme.fg("muted", truncateToWidth(header, width, "")));
      for (const group of groups.slice(0, tableRows)) {
        const label = `${this.paint(group.key, "●")} ${group.key}`;
        const share = total ? `${(group.cost / total * 100).toFixed(1)}%` : "0.0%";
        const change = this.changeText(group);
        const styledChange = change === "new" || change === "—"
          ? this.theme.fg("dim", padLeft(change, 10))
          : change.startsWith("+")
            ? this.theme.fg("warning", padLeft(change, 10))
            : this.theme.fg("success", padLeft(change, 10));
        lines.push(truncateToWidth(
          `${padRight(label, modelWidth)} ${padLeft(formatMoney(group.cost), 11)} ${padLeft(share, 9)} ${styledChange} ${padLeft(formatTokens(group.input), 7)} ${padLeft(formatTokens(group.output), 7)}`,
          width,
          "",
        ));
      }
    } else {
      lines.push(this.theme.fg("muted", `Spend by ${this.grouping} · share · vs prior`));
      for (const group of groups.slice(0, tableRows)) {
        const change = this.changeText(group);
        const suffix = `${formatMoney(group.cost)} ${(total ? group.cost / total * 100 : 0).toFixed(1)}% ${change}`;
        const nameWidth = Math.max(8, width - visibleWidth(suffix) - 3);
        lines.push(truncateToWidth(
          `${this.paint(group.key, "●")} ${padRight(group.key, nameWidth)} ${suffix}`,
          width,
          "",
        ));
      }
    }

    if (groups.length === 0) lines.push(this.theme.fg("muted", "No billed usage in this period."));
    if (this.loading) lines.push(this.theme.fg("accent", "Refreshing usage…"));
    else if (this.error) lines.push(this.theme.fg("error", this.error));

    // Fill to the terminal height so the fullscreen overlay blanks the chat
    // behind it and the hint line sits on the bottom row.
    while (lines.length < height - 1) lines.push("");
    const hints = ["←/→ period", "d daily", "w weekly", "g group", "r refresh", "t latest", "esc close"];
    if (this.mouseCapable) hints.push("or click/scroll");
    lines.push(this.theme.fg("dim", hints.join("  ")));
    return lines.map((line) => truncateToWidth(line, width, ""));
  }

  private performAction(action: Action): void {
    switch (action) {
      case "close":
        this.done();
        return;
      case "prev":
        this.offset += 1;
        break;
      case "next":
        this.offset = Math.max(0, this.offset - 1);
        break;
      case "today":
        this.offset = 0;
        break;
      case "daily":
        this.granularity = "daily";
        this.offset = 0;
        break;
      case "weekly":
        this.granularity = "weekly";
        this.offset = 0;
        break;
      case "group":
        this.grouping = this.grouping === "model" ? "provider" : "model";
        this.rebuildColors();
        break;
      case "refresh":
        if (this.loading) return;
        this.loading = true;
        this.error = undefined;
        this.tui.requestRender();
        void loadUsage()
          .then((records) => {
            this.records = records;
            this.rebuildColors();
          })
          .catch((error) => { this.error = error instanceof Error ? error.message : String(error); })
          .finally(() => {
            this.loading = false;
            this.tui.requestRender();
          });
        return;
    }
    this.tui.requestRender();
  }

  handleInput(data: string): void {
    const mouse = SGR_MOUSE.exec(data);
    if (mouse) {
      const button = Number.parseInt(mouse[1]!, 10);
      const x = Number.parseInt(mouse[2]!, 10) - 1;
      const y = Number.parseInt(mouse[3]!, 10) - 1;
      const release = mouse[4] === "m";
      if (button === 64) this.performAction("prev");
      else if (button === 65) this.performAction("next");
      else if (button === 0 && !release) {
        const region = this.regions.find((r) => r.row === y && x >= r.x1 && x < r.x2);
        if (region) this.performAction(region.action);
      }
      return;
    }

    if (matchesKey(data, Key.escape) || matchesKey(data, Key.ctrl("c")) || data === "q") {
      this.done();
      return;
    }
    if (matchesKey(data, Key.left)) this.performAction("prev");
    else if (matchesKey(data, Key.right)) this.performAction("next");
    else if (data === "d") this.performAction("daily");
    else if (data === "w") this.performAction("weekly");
    else if (data === "g") this.performAction("group");
    else if (data === "t") this.performAction("today");
    else if (data === "r") this.performAction("refresh");
  }
}

function sessionCost(ctx: ExtensionContext): number {
  let total = 0;
  for (const entry of ctx.sessionManager.getBranch()) {
    if (entry.type === "message") {
      const message = entry.message as any;
      total += finite(message.usage?.cost?.total);
    } else if (entry.type === "compaction" || entry.type === "branch_summary") {
      total += finite(entry.usage?.cost?.total);
    }
  }
  return total;
}

export default function modelUsage(pi: ExtensionAPI) {
  const updateStatus = async (ctx: ExtensionContext, pendingCost = 0) => {
    if (!ctx.hasUI) return;
    const records = await loadUsage();
    const today = utcDayStart(Date.now());
    const todayCost = records
      .filter((record) => record.timestamp >= today)
      .reduce((sum, record) => sum + record.cost, 0) + pendingCost;
    ctx.ui.setStatus(
      "model-usage",
      ctx.ui.theme.fg("dim", `usage ${formatMoney(sessionCost(ctx) + pendingCost)} · today ${formatMoney(todayCost)}`),
    );
  };

  pi.on("session_start", async (_event, ctx) => {
    await updateStatus(ctx).catch(() => undefined);
  });

  pi.on("message_end", async (event, ctx) => {
    if (event.message.role !== "assistant") return;
    const alreadyPersisted = ctx.sessionManager.getBranch().some(
      (entry) => entry.type === "message" &&
        entry.message.role === "assistant" &&
        entry.message.timestamp === event.message.timestamp,
    );
    const pendingCost = alreadyPersisted ? 0 : finite(event.message.usage?.cost?.total);
    await updateStatus(ctx, pendingCost).catch(() => undefined);
  });

  pi.registerCommand("usage", {
    description: "Show model usage and cost dashboard",
    handler: async (_args, ctx) => {
      if (ctx.mode !== "tui") {
        ctx.ui.notify("The usage dashboard is available in TUI mode.", "warning");
        return;
      }
      const records = await loadUsage();
      // Fullscreen overlay anchored at (0, 0): mouse coordinates map 1:1 to
      // rendered rows, which makes the click regions reliable.
      await ctx.ui.custom<void>(
        (tui, theme, _keybindings, done) => new UsageDashboard(records, tui, theme, done),
        { overlay: true, overlayOptions: { row: 0, col: 0, width: "100%" } },
      );
    },
  });
}
