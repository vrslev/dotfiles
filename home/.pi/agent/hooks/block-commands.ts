export default function (pi) {
  const dangerousPatterns = [
    { pattern: /\brm\s+(-rf?|--recursive)/i, reason: undefined },
    { pattern: /\bsudo\b/i, reason: undefined },
    { pattern: /\b(chmod|chown)\b.*777/i, reason: undefined },
    { pattern: /\bgit add/i, reason: "User will commit themselves" },
    { pattern: /\bgit clone/i, reason: undefined },
    { pattern: /\bgh repo clone/i, reason: undefined },
    { pattern: /\bgit checkout/i, reason: undefined },
    { pattern: /\bgit switch/i, reason: undefined },
    { pattern: /\bgit reset/i, reason: undefined },
    { pattern: /\bjira issue\s+(?!view\b)/i, reason: "Only 'jira issue view' is allowed" },
    { pattern: /\bconfluence\s+(?!read\b|search\b|info\b|find\b|--help\b)/, reason: "Destructive actions are prohibited" },
    { pattern: /\bmv\b.*-f/i, reason: undefined },
    { pattern: /\bkubectl\s+(apply|delete|create|replace)\b/i, reason: undefined },
  ];

  pi.on("tool_call", async (event: { toolName: string; input: { command: string } }, ctx) => {
    if (event.toolName !== "bash") return undefined;

    const command = event.input.command;
    for (const { pattern, reason } of dangerousPatterns) {
      if (pattern.test(command)) {
        return { block: true, reason: reason || "Blocked by system" };
      }
    }
    return undefined;
  });
}
