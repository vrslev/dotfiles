import type { ExtensionAPI, ExtensionCommandContext, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { matchesKey, truncateToWidth } from "@earendil-works/pi-tui";

const STATE_ENTRY_TYPE = "later:state";
const STATUS_KEY = "later";
const WIDGET_KEY = "later:widget";
const STATE_VERSION = 1;
const MAX_PREVIEW_LENGTH = 160;

type LaterItem = {
	id: number;
	text: string;
	createdAt: string;
};

type LaterStateSnapshot = {
	version: 1;
	items: LaterItem[];
	nextId: number;
	updatedAt: string;
};

type PickerResult =
	| { action: "fill"; ids: number[] }
	| { action: "delete"; ids: number[] }
	| { action: "cancel" };

function isLaterItem(value: unknown): value is LaterItem {
	if (!value || typeof value !== "object") return false;
	const item = value as Partial<LaterItem>;
	return (
		typeof item.id === "number" &&
		Number.isInteger(item.id) &&
		item.id > 0 &&
		typeof item.text === "string" &&
		item.text.trim().length > 0 &&
		typeof item.createdAt === "string"
	);
}

function restoreSnapshot(data: unknown): LaterStateSnapshot | undefined {
	if (!data || typeof data !== "object") return undefined;
	const snapshot = data as Partial<LaterStateSnapshot>;
	if (snapshot.version !== STATE_VERSION) return undefined;
	if (!Array.isArray(snapshot.items)) return undefined;

	const items = snapshot.items.filter(isLaterItem);
	const maxId = items.reduce((max, item) => Math.max(max, item.id), 0);
	const parsedNextId = typeof snapshot.nextId === "number" && Number.isInteger(snapshot.nextId) ? snapshot.nextId : 1;

	return {
		version: STATE_VERSION,
		items,
		nextId: Math.max(parsedNextId, maxId + 1, 1),
		updatedAt: typeof snapshot.updatedAt === "string" ? snapshot.updatedAt : new Date().toISOString(),
	};
}

function preview(text: string, maxLength = MAX_PREVIEW_LENGTH): string {
	const singleLine = text.replace(/\s+/g, " ").trim();
	if (singleLine.length <= maxLength) return singleLine;
	return `${singleLine.slice(0, Math.max(0, maxLength - 1))}…`;
}

function splitItems(text: string): string[] {
	return text
		.replace(/\r\n/g, "\n")
		.split(/\n[ \t]*\n+/)
		.map((item) => item.trim())
		.filter((item) => item.length > 0);
}

class LaterWidget {
	private cachedWidth?: number;
	private cachedLines?: string[];

	constructor(
		private readonly getItems: () => LaterItem[],
		private readonly theme: Theme,
	) {}

	render(width: number): string[] {
		if (this.cachedLines && this.cachedWidth === width) return this.cachedLines;

		const items = this.getItems();
		const lines: string[] = [];
		const title = `${this.theme.bold(this.theme.fg("accent", "Later"))} ${this.theme.fg("dim", `${items.length}`)}`;
		lines.push(truncateToWidth(title, width));

		for (const [index, item] of items.entries()) {
			const id = this.theme.fg("accent", `${index + 1}.`);
			const text = this.theme.fg("muted", preview(item.text));
			lines.push(truncateToWidth(`  ${id} ${text}`, width));
		}

		this.cachedWidth = width;
		this.cachedLines = lines;
		return lines;
	}

	invalidate(): void {
		this.cachedWidth = undefined;
		this.cachedLines = undefined;
	}
}

class LaterPicker {
	private cursor = 0;
	private selectedIds = new Set<number>();
	private cachedWidth?: number;
	private cachedLines?: string[];

	constructor(
		private readonly items: LaterItem[],
		private readonly theme: Theme,
		private readonly requestRender: () => void,
		private readonly done: (result: PickerResult) => void,
	) {}

	handleInput(data: string): void {
		if (matchesKey(data, "escape") || matchesKey(data, "ctrl+c")) {
			this.done({ action: "cancel" });
			return;
		}

		if ((matchesKey(data, "up") || data === "k") && this.cursor > 0) {
			this.cursor--;
			this.changed();
			return;
		}

		if ((matchesKey(data, "down") || data === "j") && this.cursor < this.items.length - 1) {
			this.cursor++;
			this.changed();
			return;
		}

		if (matchesKey(data, "space") || data === "x") {
			const item = this.items[this.cursor];
			if (!item) return;
			if (this.selectedIds.has(item.id)) this.selectedIds.delete(item.id);
			else this.selectedIds.add(item.id);
			this.changed();
			return;
		}

		if (matchesKey(data, "ctrl+a")) {
			if (this.selectedIds.size === this.items.length) this.selectedIds.clear();
			else this.selectedIds = new Set(this.items.map((item) => item.id));
			this.changed();
			return;
		}

		if (matchesKey(data, "enter")) {
			this.done({ action: "fill", ids: this.resultIds() });
			return;
		}

		if (data === "d") {
			this.done({ action: "delete", ids: this.resultIds() });
		}
	}

	render(width: number): string[] {
		if (this.cachedLines && this.cachedWidth === width) return this.cachedLines;

		const lines: string[] = [];
		lines.push("");
		lines.push(truncateToWidth(` ${this.theme.bold(this.theme.fg("accent", "Later"))} ${this.theme.fg("dim", "select prompts")}`, width));
		lines.push("");

		if (this.items.length === 0) {
			lines.push(truncateToWidth(`  ${this.theme.fg("dim", "No later items.")}`, width));
		} else {
			for (const [index, item] of this.items.entries()) {
				const active = index === this.cursor;
				const marker = active ? this.theme.fg("accent", "▸") : " ";
				const checked = this.selectedIds.has(item.id) ? this.theme.fg("success", "[x]") : this.theme.fg("dim", "[ ]");
				const id = this.theme.fg("accent", `${index + 1}.`);
				const text = active ? this.theme.fg("text", preview(item.text)) : this.theme.fg("muted", preview(item.text));
				lines.push(truncateToWidth(` ${marker} ${checked} ${id} ${text}`, width));
			}
		}

		lines.push("");
		lines.push(
			truncateToWidth(
				` ${this.theme.fg("dim", "↑↓/jk navigate · space/x toggle · ctrl+a all · enter fill editor · d delete · esc cancel")}`,
				width,
			),
		);
		lines.push("");

		this.cachedWidth = width;
		this.cachedLines = lines;
		return lines;
	}

	invalidate(): void {
		this.cachedWidth = undefined;
		this.cachedLines = undefined;
	}

	private resultIds(): number[] {
		if (this.selectedIds.size > 0) return this.items.filter((item) => this.selectedIds.has(item.id)).map((item) => item.id);
		const item = this.items[this.cursor];
		return item ? [item.id] : [];
	}

	private changed(): void {
		this.invalidate();
		this.requestRender();
	}
}

export default function laterExtension(pi: ExtensionAPI) {
	let items: LaterItem[] = [];
	let nextId = 1;

	function snapshot(): LaterStateSnapshot {
		return {
			version: STATE_VERSION,
			items: [...items],
			nextId,
			updatedAt: new Date().toISOString(),
		};
	}

	function persist() {
		pi.appendEntry(STATE_ENTRY_TYPE, snapshot());
	}

	function updateUi(ctx: ExtensionContext) {
		if (!ctx.hasUI) return;
		ctx.ui.setStatus(STATUS_KEY, undefined);
		if (items.length === 0) {
			ctx.ui.setWidget(WIDGET_KEY, undefined, { placement: "belowEditor" });
			return;
		}

		ctx.ui.setWidget(WIDGET_KEY, (_tui, theme) => new LaterWidget(() => items, theme), { placement: "belowEditor" });
	}

	function restore(ctx: ExtensionContext) {
		items = [];
		nextId = 1;

		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type !== "custom" || entry.customType !== STATE_ENTRY_TYPE) continue;
			const restored = restoreSnapshot(entry.data);
			if (!restored) continue;
			items = restored.items;
			nextId = restored.nextId;
		}

		updateUi(ctx);
	}

	function addItems(text: string, ctx: ExtensionContext) {
		const newTexts = splitItems(text);
		if (newTexts.length === 0) {
			ctx.ui.notify("Usage: /l <prompt>", "warning");
			return;
		}

		const newItems = newTexts.map((itemText) => ({ id: nextId++, text: itemText, createdAt: new Date().toISOString() }));
		items.push(...newItems);
		persist();
		updateUi(ctx);
		ctx.ui.notify(
			newItems.length === 1 ? `Added later item #${newItems[0]!.id}.` : `Added ${newItems.length} later items.`,
			"info",
		);
	}

	function removeIds(ids: number[], ctx: ExtensionContext): number {
		const selectedIds = new Set(ids);
		const before = items.length;
		items = items.filter((item) => !selectedIds.has(item.id));
		const removed = before - items.length;
		if (removed === 0) return 0;
		persist();
		updateUi(ctx);
		return removed;
	}

	function fillEditor(ids: number[], ctx: ExtensionCommandContext): number {
		const selectedIds = new Set(ids);
		const selected = items.filter((item) => selectedIds.has(item.id));
		if (selected.length === 0) {
			ctx.ui.notify("No matching later items.", "warning");
			return 0;
		}

		const text = selected.map((item) => item.text).join("\n\n");
		const current = ctx.ui.getEditorText();
		const next = current.trim().length > 0 ? `${current.replace(/\s+$/, "")}\n\n${text}` : text;
		ctx.ui.setEditorText(next);
		ctx.ui.notify(`Filled editor with ${selected.length} later item${selected.length === 1 ? "" : "s"}.`, "info");
		return selected.length;
	}

	async function openPicker(ctx: ExtensionCommandContext) {
		if (items.length === 0) {
			ctx.ui.notify("No later items. Add one with /l <prompt>.", "info");
			return;
		}
		if (ctx.mode !== "tui") {
			ctx.ui.notify("/l picker requires interactive mode.", "warning");
			return;
		}

		const result = await ctx.ui.custom<PickerResult>((tui, theme, _keybindings, done) => {
			return new LaterPicker([...items], theme, () => tui.requestRender(), done);
		});

		if (!result || result.action === "cancel") return;
		if (result.action === "fill") {
			if (fillEditor(result.ids, ctx) > 0) removeIds(result.ids, ctx);
			return;
		}

		const removed = removeIds(result.ids, ctx);
		ctx.ui.notify(removed === 0 ? "No matching later items." : `Deleted ${removed} later item${removed === 1 ? "" : "s"}.`, removed === 0 ? "warning" : "info");
	}

	async function handleCommand(args: string, ctx: ExtensionCommandContext) {
		const text = args.trim();
		if (text) {
			addItems(text, ctx);
			return;
		}

		await openPicker(ctx);
	}

	pi.on("session_start", async (_event, ctx) => restore(ctx));
	pi.on("session_tree", async (_event, ctx) => restore(ctx));
	pi.on("agent_start", async (_event, ctx) => updateUi(ctx));
	pi.on("agent_end", async (_event, ctx) => updateUi(ctx));

	pi.registerCommand("l", {
		description: "Save prompts for later and fill the editor from a multi-select task list",
		handler: async (args, ctx) => handleCommand(args, ctx),
	});
}
