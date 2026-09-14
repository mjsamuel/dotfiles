import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { mkdir, readFile, rename, unlink, writeFile } from "node:fs/promises";
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

async function saveStash(prompt: string): Promise<void> {
  await mkdir(dirname(stashPath), { recursive: true, mode: 0o700 });
  const temporaryPath = `${stashPath}.${process.pid}.${Date.now()}`;
  await writeFile(temporaryPath, prompt, { mode: 0o600 });
  await rename(temporaryPath, stashPath);
}

async function consumeStash(): Promise<string | undefined> {
  let prompt: string;
  try {
    prompt = await readFile(stashPath, "utf8");
  } catch (error) {
    if (isNotFound(error)) return undefined;
    throw error;
  }

  try {
    await unlink(stashPath);
  } catch (error) {
    if (isNotFound(error)) return undefined;
    throw error;
  }
  return prompt;
}

export function registerPromptStash(pi: ExtensionAPI) {
  pi.registerShortcut("ctrl+shift+s", {
    description: "Stash or restore the current prompt",
    handler: async (ctx) => {
      const currentPrompt = ctx.ui.getEditorText();

      try {
        if (currentPrompt.length === 0) {
          const stashedPrompt = await consumeStash();
          if (stashedPrompt !== undefined) ctx.ui.setEditorText(stashedPrompt);
          return;
        }

        await saveStash(currentPrompt);
        ctx.ui.setEditorText("");
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        ctx.ui.notify(`Could not update prompt stash: ${message}`, "error");
      }
    },
  });
}
