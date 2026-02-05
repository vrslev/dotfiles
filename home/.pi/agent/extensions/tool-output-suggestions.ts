export default function (pi) {
  const toolSuggestions = [
    // {
    //   pattern: /\bfind\b/,
    //   suggestion: "Warn: you have to always use fd instead of find!",
    // },
    // {
    //   pattern: /\bgrep\b/,
    //   suggestion: "Warn: you have to always use rg instead of grep!",
    // },
  ];

  pi.on("tool_result", async (event: { toolName: string; input: { command: string }; content: { type: string; text?: string }[] }) => {
    if (event.toolName !== "bash") return;

    const command = event.input.command;
    const additions = toolSuggestions
      .filter(({ pattern }) => pattern.test(command))
      .map(({ suggestion }) => suggestion);

    if (additions.length === 0) return;

    const suggestionText = additions.join("\n") + "\n";
    const modifiedContent = [...event.content];

    if (modifiedContent.length > 0 && modifiedContent[0].type === "text") {
      modifiedContent[0].text = suggestionText + (modifiedContent[0].text || "");
    } else {
      modifiedContent.unshift({ type: "text", text: suggestionText });
    }

    return { content: modifiedContent };
  });
}
