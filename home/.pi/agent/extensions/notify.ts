/**
 * Desktop Notification Extension
 *
 * Sends a native desktop notification when the agent finishes and is waiting for input.
 * Adapted from mitsupi: https://github.com/mitsuhiko/agent-stuff/blob/main/extensions/notify.ts
 * Uses OSC 777 escape sequence - no external dependencies.
 *
 * Supported terminals: Ghostty, iTerm2, WezTerm, rxvt-unicode
 * Not supported: Kitty (uses OSC 99), Terminal.app, Windows Terminal, Alacritty
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Markdown, type MarkdownTheme } from "@mariozechner/pi-tui";

/**
 * Send a desktop notification via OSC 777 escape sequence.
 */
const notify = (title: string, body: string): void => {
	// OSC 777 format: ESC ] 777 ; notify ; title ; body BEL
	process.stdout.write(`\x1b]777;notify;${title};${body}\x07`);
};

type AssistantMessage = {
	role?: string;
	content?: unknown;
	stopReason?: unknown;
	errorMessage?: unknown;
};

type AssistantSummary = {
	text: string | null;
	modelError: boolean;
};

const modelErrorStopReasons = new Set(["error", "aborted"]);

const isTextPart = (part: unknown): part is { type: "text"; text: string } =>
	Boolean(
		part &&
			typeof part === "object" &&
			"type" in part &&
			part.type === "text" &&
			"text" in part &&
			typeof part.text === "string",
	);

const isModelError = (message: AssistantMessage): boolean =>
	modelErrorStopReasons.has(String(message.stopReason)) ||
	(typeof message.errorMessage === "string" && message.errorMessage.trim().length > 0);

const extractLastAssistant = (messages: readonly AssistantMessage[]): AssistantSummary | null => {
	for (let i = messages.length - 1; i >= 0; i--) {
		const message = messages[i];
		if (message?.role !== "assistant") {
			continue;
		}

		const modelError = isModelError(message);
		const content = message.content;
		if (typeof content === "string") {
			return { text: content.trim() || null, modelError };
		}

		if (Array.isArray(content)) {
			const text = content.filter(isTextPart).map((part) => part.text).join("\n").trim();
			return { text: text || null, modelError };
		}

		return { text: null, modelError };
	}

	return null;
};

const plainMarkdownTheme: MarkdownTheme = {
	heading: (text) => text,
	link: (text) => text,
	linkUrl: () => "",
	code: (text) => text,
	codeBlock: (text) => text,
	codeBlockBorder: () => "",
	quote: (text) => text,
	quoteBorder: () => "",
	hr: () => "",
	listBullet: () => "",
	bold: (text) => text,
	italic: (text) => text,
	strikethrough: (text) => text,
	underline: (text) => text,
};

const simpleMarkdown = (text: string, width = 80): string => {
	const markdown = new Markdown(text, 0, 0, plainMarkdownTheme);
	return markdown.render(width).join("\n");
};

const formatNotification = (text: string | null): { title: string; body: string } => {
	const simplified = text ? simpleMarkdown(text) : "";
	const normalized = simplified.replace(/\s+/g, " ").trim();
	if (!normalized) {
		return { title: "Ready for input", body: "" };
	}

	const maxBody = 200;
	const body = normalized.length > maxBody ? `${normalized.slice(0, maxBody - 1)}…` : normalized;
	return { title: "π", body };
};

export default function (pi: ExtensionAPI) {
	pi.on("agent_end", async (event) => {
		const lastAssistant = extractLastAssistant(event.messages ?? []);
		if (!lastAssistant || lastAssistant.modelError) {
			return;
		}

		const { title, body } = formatNotification(lastAssistant.text);
		notify(title, body);
	});
}
