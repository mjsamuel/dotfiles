import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import autoName from "./auto-name";
import { registerClearCommand } from "./clear";
import { registerExitCommand } from "./exit";
import footer from "./footer";
import herdrSessionName from "./herdr-session-name";
import modelUsage from "./model-usage";
import piDocumentation from "./pi-documentation";
import { registerPromptStash } from "./prompt-stash";
import { registerSlashCommandGuard } from "./slash-command-guard";
import workingIndicator from "./working-indicator";

export default function user(pi: ExtensionAPI) {
  autoName(pi);
  registerClearCommand(pi);
  registerExitCommand(pi);
  registerSlashCommandGuard(pi);
  footer(pi);
  herdrSessionName(pi);
  modelUsage(pi);
  piDocumentation(pi);
  registerPromptStash(pi);
  workingIndicator(pi);
}
