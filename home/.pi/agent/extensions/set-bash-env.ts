import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type, type Static } from "typebox";

const ENV_NAME_PATTERN = "^[A-Za-z_][A-Za-z0-9_]*$";
const envNameRe = new RegExp(ENV_NAME_PATTERN);
const simpleValueRe = /^[A-Za-z0-9_./:@%+=,-]*$/;

const parameters = Type.Object(
	{
		vars: Type.Optional(
			Type.Record(
				Type.String({ pattern: ENV_NAME_PATTERN }),
				Type.Union([Type.String(), Type.Null()], {
					description: "String values set variables; null values unset variables. Omit vars to show managed variables.",
				}),
			),
		),
	},
	{ additionalProperties: false },
);

type Params = Static<typeof parameters>;

type ManagedVar = {
	hadPrevious: boolean;
	previous?: string;
	active: boolean;
};

type ResultDetails =
	| {
			mode: "status";
			managed: Array<{ name: string; value: string }>;
	  }
	| {
			mode: "patch";
			changes: Array<{ action: "set"; name: string; value: string } | { action: "unset"; name: string }>;
	  };

function validateVars(vars: Record<string, string | null>): void {
	for (const [name, value] of Object.entries(vars)) {
		if (!envNameRe.test(name)) throw new Error(`Invalid environment variable name: ${name}`);
		if (typeof value !== "string" && value !== null) throw new Error(`Invalid value for ${name}: expected string or null`);
		if (typeof value === "string" && value.includes("\0")) throw new Error(`Invalid value for ${name}: contains null byte`);
	}
}

function formatValue(value: string): string {
	if (simpleValueRe.test(value)) return value;
	return JSON.stringify(value);
}

export default function setBashEnv(pi: ExtensionAPI) {
	const managed = new Map<string, ManagedVar>();

	function remember(name: string): ManagedVar {
		const existing = managed.get(name);
		if (existing) return existing;

		const previous = process.env[name];
		const next = { hadPrevious: previous !== undefined, previous, active: false };
		managed.set(name, next);
		return next;
	}

	function restoreManaged() {
		for (const [name, state] of managed) {
			if (state.hadPrevious) process.env[name] = state.previous ?? "";
			else delete process.env[name];
		}
		managed.clear();
	}

	function managedValues(): Array<{ name: string; value: string }> {
		return [...managed.entries()]
			.filter(([, state]) => state.active)
			.map(([name]) => ({ name, value: process.env[name] ?? "" }));
	}

	function statusModelText(values: Array<{ name: string; value: string }>): string {
		if (values.length === 0) return "No environment variables managed by set_bash_env.";
		return `Managed bash environment variables: ${values.map(({ name }) => name).join(", ")}`;
	}

	function detailsText(details: ResultDetails): string {
		if (details.mode === "status") {
			if (details.managed.length === 0) return "No environment variables managed by set_bash_env.";
			return ["Managed bash environment:", ...details.managed.map(({ name, value }) => `${name}=${formatValue(value)}`)].join("\n");
		}

		return [
			...details.changes.map((change) => (change.action === "set" ? `Set ${change.name}=${formatValue(change.value)}` : `Unset ${change.name}`)),
			"",
			"Future bash calls will inherit these environment changes.",
		].join("\n");
	}

	pi.on("session_shutdown", restoreManaged);

	pi.registerTool({
		name: "set_bash_env",
		label: "Set Bash Env",
		description: "Set, unset, or show environment variables inherited by future bash tool calls. Pass vars to patch the bash environment; omit vars to show managed vars.",
		promptSnippet: "Set/unset environment variables inherited by future bash tool calls; omit vars to show managed vars.",
		promptGuidelines: [
			"Use set_bash_env when a variable must persist across multiple future bash tool calls. For one-off commands, prefer inline env assignment in bash.",
		],
		parameters,
		async execute(_toolCallId, params: Params) {
			const vars = params.vars;
			if (!vars || Object.keys(vars).length === 0) {
				const managed = managedValues();
				return {
					content: [{ type: "text", text: statusModelText(managed) }],
					details: { mode: "status", managed } satisfies ResultDetails,
				};
			}

			validateVars(vars);

			const modelLines: string[] = [];
			const changes: Extract<ResultDetails, { mode: "patch" }>["changes"] = [];
			for (const [name, value] of Object.entries(vars)) {
				const state = remember(name);
				if (value === null) {
					delete process.env[name];
					state.active = false;
					modelLines.push(`Unset ${name}`);
					changes.push({ action: "unset", name });
					continue;
				}

				process.env[name] = value;
				state.active = true;
				modelLines.push(`Set ${name}`);
				changes.push({ action: "set", name, value });
			}

			modelLines.push("", "Future bash calls will inherit these environment changes.");
			return {
				content: [{ type: "text", text: modelLines.join("\n") }],
				details: { mode: "patch", changes } satisfies ResultDetails,
			};
		},
		renderResult(result, _options, theme) {
			const details = result.details as ResultDetails | undefined;
			if (!details) return new Text("", 0, 0);
			return new Text(theme.fg("success", detailsText(details)), 0, 0);
		},
	});
}
