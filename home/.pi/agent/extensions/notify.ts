export default function (pi) {
  // @ts-ignore
  pi.on("agent_end", async (_event, ctx) => {
    await pi.exec("afplay", ["/System/Library/Sounds/Morse.aiff"]);
  });
}
