import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export function registerClearCommand(pi: ExtensionAPI) {
  pi.registerCommand("clear", {
    description: "Start a new session (alias for /new)",
    handler: async (_args, ctx) => {
      await ctx.newSession();
    },
  });
}
