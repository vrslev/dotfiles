export default function (pi) {
  const IGNORED_ERROR_MESSAGES = [
    "429 status code (no body)",
  ];

  // @ts-ignore
  pi.on("agent_end", async (event) => {
    const lastMsg = event.messages[event.messages.length - 1];
    if (lastMsg?.role !== "assistant") return;
    if (lastMsg.stopReason === "aborted") return;
    // @ts-ignore
    if (IGNORED_ERROR_MESSAGES.includes(lastMsg.errorMessage)) return;
    await pi.exec("afplay", ["/System/Library/Sounds/Morse.aiff"]);
  });
}
