export default function (pi) {
  const IGNORED_ERROR_MESSAGES = [
    "429 status code (no body)",
  ];

  // @ts-ignore
  pi.on("agent_end", async (event) => {
    const assistantMessages = event.messages.filter(m => m.role === "assistant");
    if (assistantMessages.length === 0) return;

    const lastMsg = assistantMessages[assistantMessages.length - 1];
    if (lastMsg.stopReason === "aborted") return;

    const recentAssistantMessages = assistantMessages.slice(-4);
    const allHaveErrorMessage = recentAssistantMessages.every(msg => msg.errorMessage);
    const hasIgnoredError = recentAssistantMessages.some(msg =>
      // @ts-ignore
      IGNORED_ERROR_MESSAGES.includes(msg.errorMessage)
    );

    if (allHaveErrorMessage && hasIgnoredError) return;
    await pi.exec("afplay", ["/System/Library/Sounds/Morse.aiff"]);
  });
}
