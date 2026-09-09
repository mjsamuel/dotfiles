import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export function registerExitCommand(pi: ExtensionAPI) {
  pi.registerCommand("exit", {
    description: "Exit pi cleanly",
    handler: async (_args, ctx) => {
      ctx.shutdown();
    },
  });
}
