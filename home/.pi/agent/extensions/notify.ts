export default function (pi) {
  const IGNORED_ERROR_MESSAGES = [
    "429 status code (no body)",
  ];

  // @ts-ignore
  pi.on("agent_end", async (event) => {
    const lastMsg = event.messages[event.messages.length - 1];
    const errorMsg = lastMsg?.role === "assistant" ? lastMsg.errorMessage : null;
    // @ts-ignore
    if (!IGNORED_ERROR_MESSAGES.includes(errorMsg)) {
      await pi.exec("afplay", ["/System/Library/Sounds/Morse.aiff"]);
    }
  });
}
