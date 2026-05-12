import { existsSync } from "node:fs";
import * as path from "node:path";

const GHOSTTY_SPLIT_SCRIPT = `on run argv
	set targetCwd to item 1 of argv
	set startupInput to item 2 of argv
	tell application "Ghostty"
		set cfg to new surface configuration
		set initial working directory of cfg to targetCwd
		set initial input of cfg to startupInput
		if (count of windows) > 0 then
			try
				set frontWindow to front window
				set targetTerminal to focused terminal of selected tab of frontWindow
				split targetTerminal direction right with configuration cfg
			on error
				new window with configuration cfg
			end try
		else
			new window with configuration cfg
		end if
		activate
	end tell
end run`;

function shellQuote(value) {
  if (value.length === 0) return "''";
  return `'${value.replace(/'/g, `'"'"'`)}'`;
}

function getPiInvocationParts() {
  const currentScript = process.argv[1];
  if (currentScript && existsSync(currentScript)) {
    return [process.execPath, currentScript];
  }
  const execName = path.basename(process.execPath).toLowerCase();
  const isGenericRuntime = /^(node|bun)(\.exe)?$/.test(execName);
  if (!isGenericRuntime) return [process.execPath];
  return ["pi"];
}

function buildPiStartupInput(sessionFile, prompt) {
  const parts = [...getPiInvocationParts()];
  if (sessionFile) parts.push("--session", sessionFile);
  if (prompt.length > 0) parts.push("--", prompt);
  return `${parts.map(shellQuote).join(" ")}\n`;
}

export default function (pi) {
  pi.registerCommand("split-fork", {
    description: "Open this session in a Ghostty right-split. Branches diverge in the same JSONL. Usage: /split-fork [optional prompt]",
    handler: async (args, ctx) => {
      if (process.platform !== "darwin") {
        ctx.ui.notify("/split-fork requires macOS (Ghostty AppleScript).", "warning");
        return;
      }

      const prompt = args.trim();
      const sessionFile = ctx.sessionManager.getSessionFile();
      const startupInput = buildPiStartupInput(sessionFile, prompt);

      const result = await pi.exec("osascript", ["-e", GHOSTTY_SPLIT_SCRIPT, "--", ctx.cwd, startupInput]);
      if (result.code !== 0) {
        const reason = result.stderr?.trim() || result.stdout?.trim() || "unknown osascript error";
        ctx.ui.notify(`Failed to launch Ghostty split: ${reason}`, "error");
        return;
      }

      if (sessionFile) {
        const fileName = path.basename(sessionFile);
        const suffix = prompt ? " and sent prompt" : "";
        ctx.ui.notify(`Opened ${fileName} in Ghostty split${suffix}. Branches diverge in same file.`, "info");
      } else {
        ctx.ui.notify("Opened Ghostty split (no persisted session to share).", "warning");
      }
    },
  });

  pi.registerCommand("export-fresh", {
    description: "Export session HTML by re-reading file from disk (sees branches written by other panes). Usage: /export-fresh [output.html]",
    handler: async (args, ctx) => {
      const sessionFile = ctx.sessionManager.getSessionFile();
      if (!sessionFile) {
        ctx.ui.notify("No persisted session to export.", "warning");
        return;
      }

      const [piBin, ...piArgs] = getPiInvocationParts();
      const cmdArgs = [...piArgs, "--export", sessionFile];
      const output = args.trim();
      if (output) cmdArgs.push(output);

      const result = await pi.exec(piBin, cmdArgs, { timeout: 30000 });
      if (result.code !== 0) {
        const reason = result.stderr?.trim() || result.stdout?.trim() || `exit ${result.code}`;
        ctx.ui.notify(`Export failed: ${reason}`, "error");
        return;
      }

      const combined = `${result.stdout || ""}\n${result.stderr || ""}`;
      const match = combined.match(/Exported to:\s*(.+)$/m);
      const outPath = match?.[1]?.trim() || output || combined.trim();
      ctx.ui.notify(`Exported (fresh): ${outPath}`, "info");
    },
  });
}
