import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { registerClearCommand } from "./clear";
import { registerExitCommand } from "./exit";
import { registerPromptStash } from "./prompt-stash";
import { registerToolRendering } from "./tool-rendering";

/**
 * Bring the Claude Code features we use into Pi: familiar session commands and
 * compact tool call/result rendering, while preserving Pi's built-in tool behavior.
 */
export default function claudePlugin(pi: ExtensionAPI) {
  registerClearCommand(pi);
  registerExitCommand(pi);
  registerPromptStash(pi);
  registerToolRendering(pi);
}
