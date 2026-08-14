import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function promptStash(pi: ExtensionAPI) {
  let stashedPrompt: string | undefined;

  pi.registerShortcut("ctrl+shift+s", {
    description: "Stash or restore the current prompt",
    handler: async (ctx) => {
      const currentPrompt = ctx.ui.getEditorText();

      if (stashedPrompt !== undefined && currentPrompt.length === 0) {
        ctx.ui.setEditorText(stashedPrompt);
        stashedPrompt = undefined;
        return;
      }

      if (currentPrompt.length > 0) {
        stashedPrompt = currentPrompt;
        ctx.ui.setEditorText("");
      }
    },
  });
}
