import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  writeFileSync,
} from "node:fs";
import { dirname, join } from "node:path";
import { tmpdir } from "node:os";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const DOCUMENTATION_HEADER_PREFIX =
  "Pi documentation (read only when the user asks about pi itself";
const SKILL_DESCRIPTION =
  "Reference Pi documentation and examples. Use when asked about Pi itself, its SDK, extensions, themes, skills, prompt templates, TUI, keybindings, providers, models, packages, configuration, or environment variables.";

interface PiDocumentationGlobalStore {
  __piDocumentationSkillDirectory?: string;
}

// Pi's skill loader is path-based. Keep the generated skill outside the user's
// skills directory while giving each Pi process a stable path across /reload.
const globalStore = globalThis as typeof globalThis & PiDocumentationGlobalStore;

let documentationSection: string | undefined;

function getGeneratedSkillPath(): string {
  if (!globalStore.__piDocumentationSkillDirectory) {
    globalStore.__piDocumentationSkillDirectory = mkdtempSync(
      join(tmpdir(), "pi-documentation-skill-"),
    );
  }

  return join(globalStore.__piDocumentationSkillDirectory, "SKILL.md");
}

function getExistingGeneratedSkillPath(): string | undefined {
  const directory = globalStore.__piDocumentationSkillDirectory;
  if (!directory) return undefined;

  const skillPath = join(directory, "SKILL.md");
  return existsSync(skillPath) ? skillPath : undefined;
}

/** Extract the documentation header and its contiguous list of bullet points. */
export function extractPiDocumentation(systemPrompt: string): string | undefined {
  const lines = systemPrompt.split("\n");
  const start = lines.findIndex((line) =>
    line.startsWith(DOCUMENTATION_HEADER_PREFIX),
  );

  if (start === -1) return undefined;

  let end = start + 1;
  while (end < lines.length && lines[end].startsWith("- ")) {
    end += 1;
  }

  if (end === start + 1) return undefined;

  return lines.slice(start, end).join("\n");
}

/** Remove only the block extracted earlier, preserving one blank separator. */
export function removePiDocumentation(
  systemPrompt: string,
  section: string,
): string {
  const sectionStart = systemPrompt.indexOf(section);
  if (sectionStart === -1) return systemPrompt;

  const before = systemPrompt.slice(0, sectionStart).replace(/\n+$/, "");
  const after = systemPrompt
    .slice(sectionStart + section.length)
    .replace(/^\n+/, "");

  if (!before) return after;
  if (!after) return before;

  return `${before}\n\n${after}`;
}

function renderSkill(section: string): string {
  return `---
name: pi-documentation
description: "${SKILL_DESCRIPTION}"
---

# Pi documentation

${section}
`;
}

function writeGeneratedSkill(section: string): string {
  const content = renderSkill(section);
  const skillPath = getGeneratedSkillPath();

  mkdirSync(dirname(skillPath), { recursive: true });
  if (existsSync(skillPath) && readFileSync(skillPath, "utf8") === content) {
    return skillPath;
  }

  writeFileSync(skillPath, content, "utf8");
  return skillPath;
}

export default function piDocumentation(pi: ExtensionAPI): void {
  pi.on("resources_discover", (_event, ctx) => {
    const extracted = extractPiDocumentation(ctx.getSystemPrompt());
    if (extracted) {
      documentationSection = extracted;
      writeGeneratedSkill(extracted);
    }

    const skillPath = getExistingGeneratedSkillPath();
    if (!skillPath) return undefined;

    return {
      skillPaths: [skillPath],
    };
  });

  pi.on("before_agent_start", (event) => {
    const extracted = extractPiDocumentation(event.systemPrompt);
    if (extracted) {
      documentationSection = extracted;
      writeGeneratedSkill(extracted);
    }

    if (!documentationSection) return undefined;

    const systemPrompt = removePiDocumentation(
      event.systemPrompt,
      documentationSection,
    );
    if (systemPrompt === event.systemPrompt) return undefined;

    return { systemPrompt };
  });
}
