import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const RETRY_CUSTOM_TYPE = "__retry_trigger";

export default function piRetry(pi: ExtensionAPI) {
  let pendingRetryCleanup = false;

  pi.registerCommand("retry", {
    description: "Retry the last prompt (use after aborted or errored responses)",
    handler: async (_args, ctx) => {
      if (!ctx.isIdle()) {
        ctx.ui.notify("Agent is still running.", "warning");
        return;
      }
      const branch = ctx.sessionManager.getBranch();
      let lastMsg: any = null;
      for (let i = branch.length - 1; i >= 0; i--) {
        const e = branch[i] as any;
        if (e.type !== "message") continue;
        const m = e.message;
        if (m.role === "assistant" && (m.stopReason === "error" || m.stopReason === "aborted")) continue;
        lastMsg = m;
        break;
      }
      if (lastMsg?.role !== "user") {
        ctx.ui.notify("Nothing to retry — last message is not a user message.", "warning");
        return;
      }
      pendingRetryCleanup = true;
      pi.sendMessage(
        { customType: RETRY_CUSTOM_TYPE, content: "Retrying.", display: false },
        { triggerTurn: true },
      );
    },
  });

  pi.on("context", async (event) => {
    if (!pendingRetryCleanup) return;
    pendingRetryCleanup = false;
    const cleaned = event.messages.filter(
      (msg: any) => !(msg.role === "custom" && msg.customType === RETRY_CUSTOM_TYPE),
    );
    return { messages: cleaned };
  });
}
