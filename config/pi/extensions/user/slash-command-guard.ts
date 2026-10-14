import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export function registerSlashCommandGuard(pi: ExtensionAPI) {
  pi.on("input", (event, ctx) => {
    if (event.source === "extension" || !event.text.startsWith("/")) {
      return { action: "continue" };
    }

    // Built-in commands and extension commands execute before the input event.
    const spaceIndex = event.text.indexOf(" ");
    const name = event.text.slice(1, spaceIndex === -1 ? undefined : spaceIndex);
    if (pi.getCommands().some((command) => command.name === name)) {
      return { action: "continue" };
    }

    ctx.ui.notify(`Unknown command: /${name}. Not sent to the model.`, "warning");
    return { action: "handled" };
  });
}
