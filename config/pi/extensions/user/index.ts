import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { registerClearCommand } from "./clear";
import { registerExitCommand } from "./exit";
import footer from "./footer";
import herdrAgentSummary from "./herdr-agent-summary";
import modelUsage from "./model-usage";
import piDocumentation from "./pi-documentation";
import { registerPromptStash } from "./prompt-stash";
import { registerToolRendering } from "./tool-rendering";
import workingIndicator from "./working-indicator";

export default function user(pi: ExtensionAPI) {
  registerClearCommand(pi);
  registerExitCommand(pi);
  footer(pi);
  herdrAgentSummary(pi);
  modelUsage(pi);
  piDocumentation(pi);
  registerPromptStash(pi);
  registerToolRendering(pi);
  workingIndicator(pi);
}
