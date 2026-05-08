export default function (pi) {
  pi.registerShortcut("super+r", {
    description: "Run /revdiff",
    handler: async (ctx) => {
      const saved = ctx.ui.getEditorText();
      ctx.ui.setEditorText("/revdiff");
      setImmediate(() => {
        process.stdin.emit("data", "\r");
        setImmediate(() => ctx.ui.setEditorText(saved));
      });
    },
  });
}
