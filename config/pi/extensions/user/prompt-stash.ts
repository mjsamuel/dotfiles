import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { mkdirSync, readFileSync, renameSync, unlinkSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";

const stashPath = join(
  process.env.XDG_STATE_HOME ?? join(homedir(), ".local", "state"),
  "pi",
  "prompt-stash",
);

function isNotFound(error: unknown): boolean {
  return (error as NodeJS.ErrnoException).code === "ENOENT";
}

function saveStash(prompt: string): void {
  mkdirSync(dirname(stashPath), { recursive: true, mode: 0o700 });
  const temporaryPath = `${stashPath}.${process.pid}.${Date.now()}`;
  writeFileSync(temporaryPath, prompt, { mode: 0o600 });
  renameSync(temporaryPath, stashPath);
}

function consumeStash(): string | undefined {
  let prompt: string;
  try {
    prompt = readFileSync(stashPath, "utf8");
  } catch (error) {
    if (isNotFound(error)) return undefined;
    throw error;
  }

  try {
    unlinkSync(stashPath);
  } catch (error) {
    if (isNotFound(error)) return undefined;
    throw error;
  }
  return prompt;
}

export function registerPromptStash(pi: ExtensionAPI) {
  pi.registerShortcut("ctrl+shift+s", {
    description: "Stash or restore the current prompt",
    // Pi redraws after key handling; finish editor updates before that redraw.
    handler: (ctx) => {
      const currentPrompt = ctx.ui.getEditorText();

      try {
        if (currentPrompt.length === 0) {
          const stashedPrompt = consumeStash();
          if (stashedPrompt !== undefined) ctx.ui.setEditorText(stashedPrompt);
          return;
        }

        saveStash(currentPrompt);
        ctx.ui.setEditorText("");
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        ctx.ui.notify(`Could not update prompt stash: ${message}`, "error");
      }
    },
  });
}
