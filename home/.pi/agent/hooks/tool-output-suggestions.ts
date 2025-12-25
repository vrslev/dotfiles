import type { HookAPI } from "@mariozechner/pi-coding-agent/hooks";

export default function (pi: HookAPI) {
  const toolMappings: Record<string, string> = {
    find: 'fd',
    grep: 'rg',
  };

  const suggestions: Record<string, string> = {
    find: "Note: Consider using 'fd' instead of 'find' for better performance and simpler syntax.",
    grep: "Note: Consider using 'rg' instead of 'grep' for better performance and more features.",
  };

  // Pre-compile regex patterns for better performance
  const toolPatterns: Record<string, RegExp> = {};
  const improvedPatterns: Record<string, RegExp> = {};
  
  for (const [tool, improved] of Object.entries(toolMappings)) {
    toolPatterns[tool] = new RegExp(`\\b${tool}\\b`);
    improvedPatterns[tool] = new RegExp(`\\b${improved}\\b`);
  }

  pi.on("tool_result", async (event) => {
    if (event.toolName !== "bash") return;

    const command = event.input.command as string;
    const additions: string[] = [];

    // Check for opportunities to suggest better alternatives
    for (const [tool, improved] of Object.entries(toolMappings)) {
      if (toolPatterns[tool].test(command) && !improvedPatterns[tool].test(command)) {
        additions.push(suggestions[tool]);
      }
    }

    if (additions.length === 0) return;

    const suggestionText = additions.join("\n") + "\n\n";
    const modifiedContent = [...event.content];
    
    // Prepend suggestions to the beginning of output
    if (modifiedContent.length > 0 && modifiedContent[0].type === "text") {
      modifiedContent[0].text = suggestionText + modifiedContent[0].text;
    } else {
      modifiedContent.unshift({ type: "text", text: suggestionText });
    }
    
    return { content: modifiedContent };
  });
}