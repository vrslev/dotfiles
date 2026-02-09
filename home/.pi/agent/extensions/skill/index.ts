import { Type } from "@sinclair/typebox";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

export default function (pi) {
  pi.registerTool({
    name: "skill",
    label: "Skill",
    description: "Execute a skill within the main conversation",
    parameters: Type.Object({
      skill: Type.String({ description: 'The skill name (no arguments). E.g., "pdf" or "xlsx"' }),
    }),

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      const skillName = (params as { skill: string }).skill;

      // Check common skill locations
      const skillPaths = [
        join(ctx.cwd, ".pi", "skills", skillName, "SKILL.md"),
        join(process.env.HOME || "", ".pi", "agent", "skills", skillName, "SKILL.md"),
      ];

      let skillPath = "";
      let skillContent = "";

      // Find the skill file
      for (const path of skillPaths) {
        if (existsSync(path)) {
          try {
            skillContent = readFileSync(path, "utf-8");
            skillPath = path;
            break;
          } catch {
            continue;
          }
        }
      }

      if (!skillContent) {
        return {
          content: [{ type: "text", text: `Skill "${skillName}" not found.` }],
          details: { error: true, skill: skillName },
        };
      }

      // Get base directory for relative references
      const baseDir = skillPath.replace(/\/SKILL\.md$/, "");

      // Return skill content to LLM
      return {
        content: [{ type: "text", text: `To execute, follow the ${baseDir}/SKILL.md:\n\n${skillContent}` }],
        details: { skill: skillName, path: skillPath },
      };
    }
  });
}
