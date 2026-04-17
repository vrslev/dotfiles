import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

const IDENTITY_PREFIX = "You are Claude Code, Anthropic's official CLI for Claude.";

type SystemEntry = { type?: string; text?: string; [key: string]: unknown };
type Message = { role?: string; content?: unknown; [key: string]: unknown };

export default function (pi: ExtensionAPI) {
	pi.on("before_provider_request", (event, ctx) => {
		if (ctx.model?.provider !== "anthropic") return;
		const payload = event.payload as {
			system?: SystemEntry[];
			messages?: Message[];
		};

		if (!Array.isArray(payload.system) || !Array.isArray(payload.messages)) return;

		const keptSystem: SystemEntry[] = [];
		const movedTexts: string[] = [];

		for (const entry of payload.system) {
			const txt = entry.text ?? "";
			if (txt.startsWith(IDENTITY_PREFIX)) {
				keptSystem.push(entry);
			} else if (txt.length > 0) {
				movedTexts.push(txt);
			}
		}

		if (movedTexts.length === 0) return;
		if (payload.messages.length === 0) return;

		payload.system = keptSystem;

		const injected: Message[] = movedTexts.map((txt) => ({
			role: "user",
			content: [{ type: "text", text: txt }],
		}));

		payload.messages = [...injected, ...payload.messages];
		return payload;
	});
}
