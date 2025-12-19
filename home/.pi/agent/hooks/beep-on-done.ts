import type { HookAPI } from "@mariozechner/pi-coding-agent/hooks";

export default function (pi: HookAPI) {
  pi.on("agent_end", async (event, ctx) => {
    await ctx.exec("afplay", ["/System/Library/Sounds/Glass.aiff"]);
  });
}
