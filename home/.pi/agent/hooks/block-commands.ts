import type { HookAPI } from "@mariozechner/pi-coding-agent/hooks";

export default function (pi: HookAPI) {
  const dangerousPatterns = [
    { pattern: /\brm\s+(-rf?|--recursive)/i, reason: undefined },
    { pattern: /\bsudo\b/i, reason: undefined },
    { pattern: /\b(chmod|chown)\b.*777/i, reason: undefined },
    { pattern: /\bgit add/i, reason: "User will commit themselves" },
    { pattern: /\bgit status/i, reason: "User will commit themselves" },
    { pattern: /\bgit clone/i, reason: undefined },
    { pattern: /\bgh repo clone/i, reason: undefined },
    { pattern: /\bgit checkout/i, reason: undefined },
    { pattern: /\bgit switch/i, reason: undefined },
    { pattern: /\bfind/i, reason: "Use fd" },
    { pattern: /\bgrep/i, reason: "Use rg" },
  ];

  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName !== "bash") return undefined;

    const command = event.input.command as string;
    for (const { pattern, reason } of dangerousPatterns) {
      if (pattern.test(command)) {
        return { block: true, reason: reason || "Blocked by system" };
      }
    }
    return undefined;
  });
}
