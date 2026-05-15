/**
 * Single bash tool_call mutator: quiet-env prefix (strip noise/telemetry/progress).
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";

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

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", (event) => {
		if (!isToolCallEventType("bash", event)) return;
		if (event.input.command.includes(MARKER)) return;
		event.input.command = EXPORT_PREFIX + event.input.command;
	});
}
