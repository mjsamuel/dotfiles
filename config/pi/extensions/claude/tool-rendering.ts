import { homedir } from "node:os";
import { isAbsolute, relative, resolve, sep } from "node:path";
import {
  createBashToolDefinition,
  createEditToolDefinition,
  createReadToolDefinition,
  createWriteToolDefinition,
  type BashToolDetails,
  type EditToolDetails,
  type ExtensionAPI,
  type ReadToolDetails,
  type Theme,
} from "@earendil-works/pi-coding-agent";
import { Text, wrapTextWithAnsi, type Component } from "@earendil-works/pi-tui";

type TextContent = { type: "text"; text: string };
type ToolResult = { content: unknown[]; details?: unknown };

const COLLAPSED_OUTPUT_LINES = 3;
const MAX_COLLAPSED_COMMAND_CHARS = 160;
const RESULT_CONTENT_MARGIN = 9;
const ANSI_ESCAPE =
  /[\u001B\u009B][[\]()#;?]*(?:(?:[a-zA-Z\d]*(?:;[-a-zA-Z\d\/#&.:=?%@~_]+)*)?\u0007|(?:(?:\d{1,4}(?:[;:]\d{0,4})*)?[\dA-PR-TZcf-nq-uy=><~]))/g;

function textOutput(result: ToolResult): string {
  return result.content
    .filter((item): item is TextContent => {
      if (!item || typeof item !== "object") return false;
      const content = item as Partial<TextContent>;
      return content.type === "text" && typeof content.text === "string";
    })
    .map((item) => item.text.replace(ANSI_ESCAPE, "").replace(/\r/g, ""))
    .join("\n");
}

function displayLines(output: string): string[] {
  const lines = output.split("\n");
  while (lines.length > 0 && lines.at(-1) === "") lines.pop();
  return lines;
}

function withoutToolFooter(output: string): string {
  const footer = output.indexOf("\n\n[");
  return footer === -1 ? output : output.slice(0, footer);
}

function displayCommand(command: string, expanded: boolean): string {
  if (expanded) return command.trim();

  const compact = command.replace(/\s*\n\s*/g, " ↵ ").trim();
  if (compact.length <= MAX_COLLAPSED_COMMAND_CHARS) return compact;
  return `${compact.slice(0, MAX_COLLAPSED_COMMAND_CHARS).trimEnd()}…`;
}

function displayPath(path: string, cwd: string): string {
  if (!path) return path;

  const absolutePath = resolve(cwd, path);
  const cwdRelativePath = relative(cwd, absolutePath);
  if (!cwdRelativePath) return ".";
  if (!cwdRelativePath.startsWith(`..${sep}`) && cwdRelativePath !== "..") {
    return cwdRelativePath.split(sep).join("/");
  }

  if (!isAbsolute(path)) return path;

  const home = homedir();
  const homeRelativePath = relative(home, absolutePath);
  if (!homeRelativePath) return "~";
  if (!homeRelativePath.startsWith(`..${sep}`) && homeRelativePath !== "..") {
    return `~/${homeRelativePath.split(sep).join("/")}`;
  }
  return path;
}

function formatJsonLine(line: string): string {
  try {
    const parsed = JSON.parse(line);
    const compact = JSON.stringify(parsed);
    const pretty = JSON.stringify(parsed, null, 2);
    if (!compact || !pretty) return line;

    // Only reformat when parsing and serializing preserves the original data.
    const withoutWhitespace = (value: string) => value.replace(/\s+/g, "");
    if (withoutWhitespace(line) !== withoutWhitespace(compact)) return line;
    return pretty;
  } catch {
    return line;
  }
}

function updateText(previous: unknown, content: string): Text {
  const text = previous instanceof Text ? previous : new Text("", 0, 0);
  text.setText(content);
  return text;
}

function callLine(
  label: string,
  value: string,
  theme: Theme,
  context: { isError: boolean; isPartial: boolean; lastComponent?: unknown },
  suffix = "",
): Text {
  const bulletColor = context.isError
    ? "error"
    : context.isPartial
      ? "accent"
      : "success";
  const content =
    theme.fg(bulletColor, "●") +
    " " +
    theme.fg("text", theme.bold(label)) +
    theme.fg("muted", `(${value})${suffix}`);
  return updateText(context.lastComponent, content);
}

function resultTree(
  lines: string[],
  theme: Theme,
  context: { isError: boolean; lastComponent?: unknown },
): Text {
  const color = context.isError ? "error" : "toolOutput";
  const rendered =
    lines.length > 0 ? lines : [context.isError ? "Failed" : "Done"];
  const content = rendered
    .map((line, index) => {
      const branch = index === 0 ? "  ⎿ " : "    ";
      return theme.fg("dim", branch) + theme.fg(color, line || " ");
    })
    .join("\n");
  return updateText(context.lastComponent, content);
}

// Count wrapped terminal rows rather than newline-delimited rows so a single long
// output line cannot make a collapsed tool result arbitrarily tall.
class PreviewResultTree implements Component {
  private lines: string[] = [];
  private expanded = false;
  private preferTail = false;
  private theme!: Theme;
  private isError = false;

  update(
    lines: string[],
    expanded: boolean,
    preferTail: boolean,
    theme: Theme,
    isError: boolean,
  ): void {
    this.lines = lines.flatMap((line) => formatJsonLine(line).split("\n"));
    this.expanded = expanded;
    this.preferTail = preferTail;
    this.theme = theme;
    this.isError = isError;
  }

  invalidate(): void {}

  render(width: number): string[] {
    const color = this.isError ? "error" : "toolOutput";
    // Match Claude Code's safety margin so wrapped output stays within the tool tree.
    const contentWidth = Math.max(width - RESULT_CONTENT_MARGIN, 10);
    const visualLines = this.lines.flatMap((line) =>
      wrapTextWithAnsi(this.theme.fg(color, line || " "), contentWidth),
    );

    let visible = visualLines;
    let hidden = 0;
    if (!this.expanded && visualLines.length > COLLAPSED_OUTPUT_LINES + 1) {
      visible = this.preferTail
        ? visualLines.slice(-COLLAPSED_OUTPUT_LINES)
        : visualLines.slice(0, COLLAPSED_OUTPUT_LINES);
      hidden = visualLines.length - visible.length;
    }

    const rendered =
      visible.length > 0
        ? visible
        : [this.theme.fg(color, this.isError ? "Failed" : "Done")];
    const result = rendered.map((line, index) => {
      const branch = index === 0 ? "  ⎿ " : "    ";
      return this.theme.fg("dim", branch) + line;
    });

    if (hidden > 0) {
      const footer = `… +${hidden} line${hidden === 1 ? "" : "s"} (ctrl+o to expand)`;
      result.push(this.theme.fg("dim", "    " + footer));
    }
    return result;
  }
}

function previewResultTree(
  lines: string[],
  expanded: boolean,
  preferTail: boolean,
  theme: Theme,
  context: { isError: boolean; lastComponent?: unknown },
): PreviewResultTree {
  const component =
    context.lastComponent instanceof PreviewResultTree
      ? context.lastComponent
      : new PreviewResultTree();
  component.update(lines, expanded, preferTail, theme, context.isError);
  return component;
}

function diffStats(diff: string): { additions: number; removals: number } {
  let additions = 0;
  let removals = 0;

  for (const line of diff.split("\n")) {
    if (line.startsWith("+") && !line.startsWith("+++")) additions++;
    if (line.startsWith("-") && !line.startsWith("---")) removals++;
  }

  return { additions, removals };
}

export function registerToolRendering(pi: ExtensionAPI) {
  const cwd = process.cwd();

  const read = createReadToolDefinition(cwd);
  pi.registerTool({
    ...read,
    renderShell: "self",
    renderCall(args, theme, context) {
      const range: string[] = [];
      if (args.offset) range.push(`offset ${args.offset}`);
      if (args.limit) range.push(`limit ${args.limit}`);
      const suffix =
        range.length > 0 ? theme.fg("dim", ` · ${range.join(", ")}`) : "";
      return callLine(
        "Read",
        args.path ? displayPath(args.path, cwd) : "…",
        theme,
        context,
        suffix,
      );
    },
    renderResult(result, { expanded }, theme, context) {
      const output = textOutput(result);
      if (context.isError) {
        return previewResultTree(
          displayLines(output),
          expanded,
          true,
          theme,
          context,
        );
      }

      if (
        result.content.some(
          (item) => (item as { type?: string })?.type === "image",
        )
      ) {
        return resultTree(["Read image"], theme, context);
      }

      const details = result.details as ReadToolDetails | undefined;
      const body = withoutToolFooter(output);
      const lineCount =
        details?.truncation?.outputLines ??
        (body ? body.split("\n").length : 0);
      const summary = details?.truncation?.truncated
        ? `Read ${lineCount} lines · truncated from ${details.truncation.totalLines}`
        : `Read ${lineCount} line${lineCount === 1 ? "" : "s"}`;
      const lines = expanded ? [summary, ...displayLines(body)] : [summary];
      return resultTree(lines, theme, context);
    },
  });

  const bash = createBashToolDefinition(cwd);
  pi.registerTool({
    ...bash,
    renderShell: "self",
    renderCall(args, theme, context) {
      const suffix = args.timeout
        ? theme.fg("dim", ` · ${args.timeout}s timeout`)
        : "";
      return callLine(
        "Bash",
        displayCommand(args.command ?? "…", context.expanded),
        theme,
        context,
        suffix,
      );
    },
    renderResult(result, { expanded, isPartial }, theme, context) {
      const details = result.details as BashToolDetails | undefined;
      let lines = displayLines(textOutput(result));

      if (
        lines.length === 0 ||
        (lines.length === 1 && lines[0] === "(no output)")
      ) {
        lines = [isPartial ? "Running…" : "Done"];
      }
      if (details?.truncation?.truncated && !expanded) {
        lines.push(
          `Output truncated · ${details.truncation.totalLines} lines total`,
        );
      }

      return previewResultTree(
        lines,
        expanded,
        isPartial || context.isError,
        theme,
        context,
      );
    },
  });

  const edit = createEditToolDefinition(cwd);
  pi.registerTool({
    ...edit,
    renderShell: "self",
    renderCall(args, theme, context) {
      return callLine(
        "Update",
        args.path ? displayPath(args.path, cwd) : "…",
        theme,
        context,
      );
    },
    renderResult(result, { expanded, isPartial }, theme, context) {
      if (isPartial) return resultTree(["Updating…"], theme, context);
      if (context.isError) {
        return previewResultTree(
          displayLines(textOutput(result)),
          expanded,
          true,
          theme,
          context,
        );
      }

      const details = result.details as EditToolDetails | undefined;
      if (!details?.diff) return resultTree(["Updated file"], theme, context);

      const { additions, removals } = diffStats(details.diff);
      const summary = `Added ${additions} line${additions === 1 ? "" : "s"}, removed ${removals} line${removals === 1 ? "" : "s"}`;
      if (!expanded) return resultTree([summary], theme, context);

      const diff = details.diff.split("\n").map((line) => {
        if (line.startsWith("+") && !line.startsWith("+++"))
          return theme.fg("toolDiffAdded", line);
        if (line.startsWith("-") && !line.startsWith("---"))
          return theme.fg("toolDiffRemoved", line);
        return theme.fg("toolDiffContext", line);
      });
      return resultTree([summary, ...diff], theme, context);
    },
  });

  const write = createWriteToolDefinition(cwd);
  pi.registerTool({
    ...write,
    renderShell: "self",
    renderCall(args, theme, context) {
      return callLine(
        "Write",
        args.path ? displayPath(args.path, cwd) : "…",
        theme,
        context,
      );
    },
    renderResult(result, { expanded, isPartial }, theme, context) {
      if (isPartial) return resultTree(["Writing…"], theme, context);
      if (context.isError) {
        return previewResultTree(
          displayLines(textOutput(result)),
          expanded,
          true,
          theme,
          context,
        );
      }

      const content = context.args.content ?? "";
      const lineCount = content ? content.split("\n").length : 0;
      const byteCount = Buffer.byteLength(content, "utf8");
      return resultTree(
        [
          `Wrote ${lineCount} line${lineCount === 1 ? "" : "s"} · ${byteCount.toLocaleString()} bytes`,
        ],
        theme,
        context,
      );
    },
  });
}
