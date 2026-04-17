export default function (pi) {
  const dangerousPatterns = [
    { pattern: /\brm\s+(-rf?|--recursive)/i },
    { pattern: /\bsudo\b/i },
    { pattern: /\b(chmod|chown)\b.*777/i },
    { pattern: /\bjira issue\s+(?!view\b|list\b)/i, reason: "Only 'jira issue view' and 'jira issue list' are allowed" },
    { pattern: /\bconfluence\s+(?!read\b|search\b|info\b|find\b|--help\b)/, reason: "Destructive actions are prohibited" },
    { pattern: /\bmv\b.*-f/i },
    { pattern: /\bkubectl\s+(apply|delete|create|replace)\b/i },
  ];

  pi.on("tool_call", async (event: { toolName: string; input: { command: string } }) => {
    if (event.toolName !== "bash") return undefined;
    for (const { pattern } of dangerousPatterns) {
      if (pattern.test(event.input.command)) {
        return { block: true, reason: "Command blocked: such things are discouraged. If you must do it, ask user to run it." };
      }
    }
  });
}
