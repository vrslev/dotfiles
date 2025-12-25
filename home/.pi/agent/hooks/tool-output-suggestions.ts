import type { HookAPI } from "@mariozechner/pi-coding-agent/hooks";

export default function (pi: HookAPI) {
  const toolSuggestions: { suggestion: string; pattern: RegExp }[] = [
    {
      pattern: /\bfind\b/,
      suggestion: "Tip: use fd",
    },
    {
      pattern: /\bgrep\b/,
      suggestion: "Tip: use rg",
    },
  ];

  pi.on("tool_result", async (event) => {
    if (event.toolName !== "bash") return;

    const command = event.input.command as string;
    const additions: string[] = [];

    for (const { suggestion: tip, pattern } of toolSuggestions) {
      if (pattern.test(command)) {
        additions.push(tip);
      }
    }

    if (additions.length === 0) return;

    const suggestionText = additions.join("\n") + "\n\n";
    const modifiedContent = [...event.content];

    if (modifiedContent.length > 0 && modifiedContent[0].type === "text") {
      modifiedContent[0].text = suggestionText + modifiedContent[0].text;
    } else {
      modifiedContent.unshift({ type: "text", text: suggestionText });
    }

    return { content: modifiedContent };
  });
}
