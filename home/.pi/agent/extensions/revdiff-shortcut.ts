export default function (pi) {
  pi.registerShortcut("super+r", {
    description: "Run /revdiff",
    handler: async (ctx) => {
      ctx.ui.setEditorText("/revdiff");
      setImmediate(() => process.stdin.emit("data", "\r"));
    },
  });
}
