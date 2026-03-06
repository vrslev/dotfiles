/**
 * Continue-on-wake extension.
 *
 * Automatically resumes the agent session after the system wakes from sleep,
 * but only if the session ended with an error. This is useful for handling
 * transient failures (network issues, rate limits, etc.) that occurred while
 * the laptop was asleep.
 *
 * Uses macOS `kern.waketime` sysctl to detect recent wake events.
 *
 * Usage:
 *   pi -e ~/.pi/agent/extensions/continue-on-wake.ts
 */

import { execSync } from "node:child_process";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

/**
 * Check if the system woke from sleep within the last 60 seconds.
 */
function wasRecentlyWoken(): boolean {
  try {
    const output = execSync("sysctl -n kern.waketime", { encoding: "utf8" }).trim();
    if (!output || output === "0") return false;
    const match = output.match(/sec\s*=\s*(\d+)/);
    if (match) {
      const wakeTime = parseInt(match[1]);
      const now = Math.floor(Date.now() / 1000);
      return (now - wakeTime) < 60;
    }
  } catch {
    return false;
  }
  return false;
}

/**
 * Get the error message from the last assistant message in the current session branch, if any.
 */
function getLastErrorMessage(ctx: ExtensionContext): string | null {
  const branch = ctx.sessionManager.getBranch();
  for (let i = branch.length - 1; i >= 0; i--) {
    const entry = branch[i];
    if (entry.type === "message" && entry.message.role === "assistant") {
      return entry.message.errorMessage ?? null;
    }
  }
  return null;
}

export default function (pi: ExtensionAPI) {
  let timer: NodeJS.Timeout | null = null;
  let notified = false;

  pi.on("session_start", (_, ctx) => {
    timer = setInterval(() => {
      const woke = wasRecentlyWoken();
      if (woke && !notified) {
        const lastError = getLastErrorMessage(ctx);
        if (lastError) {
          notified = true;
          pi.sendUserMessage("Continue from where we left off", { deliverAs: "steer" });
        }
      } else if (!woke) {
        notified = false;
      }
    }, 3000);
  });

  pi.on("session_shutdown", () => {
    if (timer) clearInterval(timer);
  });
}
