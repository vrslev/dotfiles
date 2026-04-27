/**
 * Single bash tool_call mutator:
 *   1. rtk rewrite (token savings via rtk registry) — opt-in via BASH_REWRITE_RTK=1
 *   2. quiet-env prefix (strip noise/telemetry/progress)
 *
 * Order matters: rewrite first so rtk sees the raw user command,
 * then wrap the rewritten command with the env preamble.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";
import { execSync, spawnSync } from "node:child_process";

const QUIET_ENV: Record<string, string> = {
	NO_COLOR: "1",
	CLICOLOR: "0",
	CLICOLOR_FORCE: "0",
	TERM: "dumb",
	CI: "1",
	PAGER: "cat",
	GIT_PAGER: "cat",
	GIT_ADVICE: "0",

	NPM_CONFIG_FUND: "false",
	NPM_CONFIG_AUDIT: "false",
	NPM_CONFIG_PROGRESS: "false",
	NPM_CONFIG_LOGLEVEL: "error",
	NODE_NO_WARNINGS: "1",

	PIP_DISABLE_PIP_VERSION_CHECK: "1",
	PIP_NO_INPUT: "1",
	PIP_QUIET: "1",
	UV_NO_PROGRESS: "1",
	PYTHONDONTWRITEBYTECODE: "1",

	CARGO_TERM_COLOR: "never",
	CARGO_TERM_PROGRESS_WHEN: "never",

	DOCKER_CLI_HINTS: "false",
	BUILDKIT_PROGRESS: "plain",

	HOMEBREW_NO_ENV_HINTS: "1",
	HOMEBREW_NO_AUTO_UPDATE: "1",
	HOMEBREW_NO_INSTALL_CLEANUP: "1",

	DO_NOT_TRACK: "1",
	DOTNET_CLI_TELEMETRY_OPTOUT: "1",
	NEXT_TELEMETRY_DISABLED: "1",
	GATSBY_TELEMETRY_DISABLED: "1",
	DISABLE_OPENCOLLECTIVE: "1",
	ADBLOCK: "1",
	SCARF_ANALYTICS: "false",
	TURBO_NO_UPDATE_NOTIFIER: "1",
};

const MARKER = "# quiet-env injected";

const EXPORT_PREFIX = `${MARKER}\n${Object.entries(QUIET_ENV)
	.map(([k, v]) => `export ${k}=${JSON.stringify(v)}`)
	.join("; ")}\n`;

let rtkAvailable: boolean | null = null;

function checkRtk(): boolean {
	if (rtkAvailable !== null) return rtkAvailable;
	try {
		execSync("which rtk", { stdio: "ignore" });
		rtkAvailable = true;
	} catch {
		rtkAvailable = false;
	}
	return rtkAvailable;
}

function tryRewrite(command: string): string | null {
	const res = spawnSync("rtk", ["rewrite", command], {
		encoding: "utf-8",
		timeout: 2000,
	});
	if (res.error) return null;
	const result = (res.stdout ?? "").trim();
	return result && result !== command ? result : null;
}

export default function (pi: ExtensionAPI) {
	const debug = process.env.BASH_REWRITE_DEBUG === "1";
	const rtkEnabled = process.env.BASH_REWRITE_RTK === "1";
	const rtkOn = rtkEnabled && checkRtk();
	if (rtkEnabled && !rtkOn && debug) {
		console.warn("[bash-rewrite] rtk not in PATH — skipping rewrite, env prefix still active");
	}

	pi.on("tool_call", (event) => {
		if (!isToolCallEventType("bash", event)) return;
		if (event.input.command.includes(MARKER)) return;

		let cmd = event.input.command;

		if (rtkOn) {
			const rewritten = tryRewrite(cmd);
			if (rewritten) {
				if (debug) console.log(`[bash-rewrite] rtk: ${cmd} -> ${rewritten}`);
				cmd = rewritten;
			}
		}

		event.input.command = EXPORT_PREFIX + cmd;
	});
}
