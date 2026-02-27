/**
 * Continues processing after laptop wake from sleep.
 *
 * Detects wake by checking if kern.waketime is within the last 60 seconds.
 *
 * Usage:
 *   pi -e examples/extensions/wake-on-sleep.ts
 */

import { execSync } from "node:child_process";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

function wasRecentlyWoken(): boolean {
  try {
    const output = execSync("sysctl -n kern.waketime", { encoding: "utf8" }).trim();
    if (!output || output === "0") return false;
    const match = output.match(/sec\s*=\s*(\d+)/);
    if (match) {
      const wakeTime = parseInt(match[1]);
      const now = Math.floor(Date.now() / 1000);
      console.log(now - wakeTime)
      return (now - wakeTime) < 60;
    }
  } catch {
    return false;
  }
  return false;
}

export default function (pi: ExtensionAPI) {
  let timer: NodeJS.Timeout | null = null;
  let notified = false;

  pi.on("session_start", (_, ctx) => {
    timer = setInterval(() => {
      const woke = wasRecentlyWoken();
      ctx.ui.notify(woke, "info");
      if (woke && !notified) {
        notified = true;
        pi.sendUserMessage("Continue from where we left off", { deliverAs: "steer" });
      } else if (!woke) {
        notified = false;
      }
    }, 3000);
  });

  pi.on("session_shutdown", () => {
    if (timer) clearInterval(timer);
  });
}
