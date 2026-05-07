import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const SPLIT_KEY = "d";
const SPLIT_MODIFIER = "command";
const POST_SPLIT_DELAY = 0.3;

function escapeForAppleScript(value: string): string {
  return value.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
}

async function sessionExists(pi: ExtensionAPI, repo: string): Promise<boolean> {
  const result = await pi.exec("hunk", ["session", "get", "--repo", repo, "--json"]);
  return result.code === 0;
}

async function isGitRepo(pi: ExtensionAPI, repo: string): Promise<boolean> {
  const result = await pi.exec("git", ["-C", repo, "rev-parse", "--is-inside-work-tree"]);
  return result.code === 0 && result.stdout.trim() === "true";
}

async function isDarkMode(pi: ExtensionAPI): Promise<boolean> {
  const result = await pi.exec("osascript", [
    "-e",
    'tell application "System Events" to tell appearance preferences to return dark mode',
  ]);
  return result.code === 0 && result.stdout.trim() === "true";
}

async function splitGhostty(pi: ExtensionAPI, repo: string): Promise<void> {
  const themeFlag = (await isDarkMode(pi)) ? "" : " --theme paper";
  const command = `cd ${JSON.stringify(repo)} && hunk diff --watch${themeFlag}`;
  const escaped = escapeForAppleScript(command);
  const script = [
    'tell application "Ghostty" to activate',
    "delay 0.08",
    'tell application "System Events"',
    `keystroke "${SPLIT_KEY}" using ${SPLIT_MODIFIER} down`,
    `delay ${POST_SPLIT_DELAY}`,
    `keystroke "${escaped}"`,
    "key code 36",
    "end tell",
  ];
  const args: string[] = [];
  for (const line of script) {
    args.push("-e", line);
  }
  const result = await pi.exec("osascript", args);
  if (result.code !== 0) {
    throw new Error(`osascript failed: ${result.stderr.trim()}`);
  }
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("hunk", {
    description: "Split current ghostty pane and run hunk diff --watch for current repo",
    handler: async (_args, ctx) => {
      const repo = process.cwd();
      if (!(await isGitRepo(pi, repo))) {
        ctx.ui.notify(`Not a git repo: ${repo}`, "error");
        return;
      }
      if (await sessionExists(pi, repo)) {
        ctx.ui.notify("Hunk session already running for this repo", "info");
        return;
      }
      try {
        await splitGhostty(pi, repo);
        ctx.ui.notify("Sent split + hunk command to Ghostty", "info");
      } catch (error) {
        ctx.ui.notify(`Failed to split Ghostty: ${(error as Error).message}`, "error");
      }
    },
  });

  pi.registerCommand("hunk-reload", {
    description: "Force the live hunk window to reload the working diff",
    handler: async (_args, ctx) => {
      const result = await pi.exec("hunk", ["session", "reload", "--repo", process.cwd(), "--", "diff"]);
      if (result.code === 0) {
        ctx.ui.notify("Reloaded hunk session", "info");
      } else {
        ctx.ui.notify(`hunk reload failed: ${result.stderr.trim()}`, "error");
      }
    },
  });
}
