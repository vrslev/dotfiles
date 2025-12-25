export default function (pi) {
  pi.on("agent_end", async (_event, ctx) => {
    await ctx.exec("afplay", ["/System/Library/Sounds/Glass.aiff"]);
  });
}
