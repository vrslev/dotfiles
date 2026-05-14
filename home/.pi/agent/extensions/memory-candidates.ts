/**
 * memory-candidates — background extraction of durable facts from sessions
 * into a per-project candidates file, with a TUI to promote/discard into AGENTS.md.
 *
 * Storage layout:
 *   ~/.pi/agent/memory-candidates/global.md
 *   ~/.pi/agent/memory-candidates/<basename>-<sha12>.md
 *
 * Triggers:
 *   - every N turn_ends (default 10), gated by min user turns
 *   - session_shutdown (best-effort flush)
 *
 * Promotion targets:
 *   - global candidates  →  ~/.pi/agent/AGENTS.md
 *   - project candidates →  <cwd>/AGENTS.md
 *
 * No system-prompt injection: pi auto-loads AGENTS.md files.
 */

import type { ExtensionAPI, ExtensionContext, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import {
	appendFileSync,
	existsSync,
	mkdirSync,
	readFileSync,
	writeFileSync,
} from "node:fs";
import { homedir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { createHash } from "node:crypto";
import {
	Key,
	matchesKey,
	truncateToWidth,
} from "@earendil-works/pi-tui";

const TURN_INTERVAL = 20;
const MIN_USER_TURNS = 3;
const MIN_TRANSCRIPT_PARTS = 4;
const RECENT_MESSAGES = 40;
const REVIEW_TIMEOUT_MS = 120_000;
const SHUTDOWN_TIMEOUT_MS = 30_000;
const DEFAULT_MODEL = "anthropic/claude-sonnet-4-6";
const AGENTS_HEADING = "## Memory";

const CANDIDATES_DIR = join(homedir(), ".pi", "agent", "memory-candidates");
const GLOBAL_AGENTS_MD = join(homedir(), ".pi", "agent", "AGENTS.md");

type Scope = "global" | "project";

interface ProjectPaths {
	globalCandidates: string;
	projectCandidates: string | null;
	projectName: string | null;
	projectAgentsMd: string | null;
}

function resolveProjectPaths(cwd: string): ProjectPaths {
	mkdirSync(CANDIDATES_DIR, { recursive: true });
	const resolvedCwd = resolve(cwd);
	const resolvedHome = resolve(homedir());
	const globalCandidates = join(CANDIDATES_DIR, "global.md");
	if (resolvedCwd === resolvedHome) {
		return {
			globalCandidates,
			projectCandidates: null,
			projectName: null,
			projectAgentsMd: null,
		};
	}
	const basename = resolvedCwd.split("/").pop() || "project";
	const hash = createHash("sha256").update(resolvedCwd).digest("hex").slice(0, 12);
	return {
		globalCandidates,
		projectCandidates: join(CANDIDATES_DIR, `${basename}-${hash}.md`),
		projectName: basename,
		projectAgentsMd: join(resolvedCwd, "AGENTS.md"),
	};
}

function collectTranscript(entries: unknown[]): string[] {
	const out: string[] = [];
	for (const entry of entries) {
		if (!entry || typeof entry !== "object") continue;
		if ((entry as { type?: unknown }).type !== "message") continue;
		const msg = (entry as { message?: unknown }).message;
		if (!msg || typeof msg !== "object") continue;
		const { role, content } = msg as { role?: unknown; content?: unknown };
		if (typeof role !== "string") continue;
		let text = "";
		if (typeof content === "string") {
			text = content;
		} else if (Array.isArray(content)) {
			text = content
				.filter((b): b is { type: string; text: string } =>
					!!b && typeof b === "object" && (b as { type?: unknown }).type === "text" && typeof (b as { text?: unknown }).text === "string",
				)
				.map((b) => b.text)
				.join("\n");
		}
		if (!text.trim()) continue;
		out.push(`[${role.toUpperCase()}]: ${text.slice(0, 800)}`);
	}
	return out;
}

function readFileSafe(path: string | null): string {
	if (!path || !existsSync(path)) return "";
	try {
		return readFileSync(path, "utf-8");
	} catch {
		return "";
	}
}

function extractBulletLines(text: string): string[] {
	const out: string[] = [];
	for (const raw of text.split("\n")) {
		const m = raw.match(/^\s*-\s+(.+)$/);
		if (m) out.push(m[1].trim());
	}
	return out;
}

function buildExtractionPrompt(
	transcript: string,
	paths: ProjectPaths,
	existingCandidates: { global: string; project: string },
	existingAgentsMd: { global: string; project: string },
): string {
	const projectLine = paths.projectName
		? `Working in project "${paths.projectName}".`
		: "Working in home directory; no project scope available.";
	const alreadyGlobal = [
		...extractBulletLines(existingAgentsMd.global),
		...extractBulletLines(existingCandidates.global),
	];
	const alreadyProject = [
		...extractBulletLines(existingAgentsMd.project),
		...extractBulletLines(existingCandidates.project),
	];
	return [
		"Extract repo conventions and durable user preferences suitable for AGENTS.md.",
		"AGENTS.md is auto-loaded by every future agent session in this directory.",
		"Imagine writing a CONTRIBUTING note for a teammate joining the project.",
		"The bar is high: prefer emitting nothing over emitting noise.",
		"",
		"INCLUDE only:",
		"  - Repo conventions: file layout, naming, where new code/data goes",
		"  - Workflow patterns: build/test/lint/deploy commands, branch or PR norms",
		"  - Tooling gotchas: non-obvious behaviour of project tools, APIs, or libraries",
		"  - Durable user preferences expressed in the session (style, tool choices)",
		"",
		"EXCLUDE:",
		"  - One-off analysis results, computed numbers, amounts, dates, names tied to one dataset",
		"  - Personal, financial, or otherwise sensitive data",
		"  - Narration of what just happened in this session ('we fixed X by doing Y')",
		"  - Pi-internal trivia, generic LLM advice, or agent hygiene",
		"  - Anything likely stale within a week, or only meaningful with this session's context",
		"  - Restatements or paraphrases of ALREADY KNOWN lines below",
		"  - Lines that name a specific file/path/value the user just edited — extract the pattern, not the change",
		"  - Anything only true because of an edit made in THIS session — the line must generalize beyond the immediate change",
		"",
		"Output ONE fact per line, exact format:",
		"  [global] <fact>     — cross-project user preference (rare; default to [project])",
		"  [project] <fact>    — convention or gotcha specific to this codebase",
		"",
		"Rules:",
		"  - Terse, imperative when possible. No explanation, no justification.",
		"  - If unsure whether a line belongs in AGENTS.md, drop it.",
		"  - If nothing meets the bar, output nothing at all.",
		"  - No preamble, no closing remarks, no markdown headings — just bare lines.",
		"  - Generalization test: a line must still be accurate next month even if every edit from this session is reverted.",
		"",
		"CONTEXT:",
		projectLine,
		"",
		"ALREADY KNOWN (global):",
		alreadyGlobal.length === 0 ? "(none)" : alreadyGlobal.map((l) => `- ${l}`).join("\n"),
		"",
		"ALREADY KNOWN (project):",
		alreadyProject.length === 0 ? "(none)" : alreadyProject.map((l) => `- ${l}`).join("\n"),
		"",
		"CONVERSATION:",
		transcript,
	].join("\n");
}

interface Extracted {
	global: string[];
	project: string[];
}

function parseExtraction(stdout: string): Extracted {
	const out: Extracted = { global: [], project: [] };
	for (const raw of stdout.split("\n")) {
		const line = raw.trim();
		if (!line) continue;
		const mg = line.match(/^\[global\]\s+(.+)$/i);
		if (mg) {
			out.global.push(mg[1].trim());
			continue;
		}
		const mp = line.match(/^\[project\]\s+(.+)$/i);
		if (mp) {
			out.project.push(mp[1].trim());
		}
	}
	return out;
}

const STOPWORDS = new Set([
	"the", "a", "an", "is", "are", "was", "were", "be", "to", "of", "in", "on",
	"for", "with", "and", "or", "but", "not", "never", "always", "this", "that",
	"use", "using", "prefer", "prefers", "preferred", "do", "don", "t",
	"it", "as", "by", "at", "all", "any", "will", "should", "i", "you",
]);

function tokenize(line: string): Set<string> {
	const out = new Set<string>();
	for (const tok of line.toLowerCase().split(/[^a-z0-9]+/)) {
		if (!tok || tok.length < 2) continue;
		if (STOPWORDS.has(tok)) continue;
		out.add(tok);
	}
	return out;
}

function jaccard(a: Set<string>, b: Set<string>): number {
	if (a.size === 0 || b.size === 0) return 0;
	let intersect = 0;
	for (const t of a) if (b.has(t)) intersect++;
	const union = a.size + b.size - intersect;
	return union === 0 ? 0 : intersect / union;
}

const DEDUP_JACCARD_THRESHOLD = 0.55;

function collectExistingTokenSets(path: string | null): Set<string>[] {
	if (!path) return [];
	const sets: Set<string>[] = [];
	for (const raw of readFileSafe(path).split("\n")) {
		const m = raw.match(/^\s*-\s+(.+)$/);
		if (m) sets.push(tokenize(m[1]));
	}
	return sets;
}

function isDuplicate(candidate: Set<string>, existing: Set<string>[]): boolean {
	for (const e of existing) {
		if (jaccard(candidate, e) >= DEDUP_JACCARD_THRESHOLD) return true;
	}
	return false;
}

function appendCandidates(path: string, lines: string[], cwd: string, existing: Set<string>[]): number {
	const fresh: string[] = [];
	for (const l of lines) {
		const toks = tokenize(l);
		if (isDuplicate(toks, existing)) continue;
		existing.push(toks);
		fresh.push(l);
	}
	if (fresh.length === 0) return 0;
	const ts = new Date().toISOString();
	const block = `\n<!-- ${ts} cwd=${cwd} -->\n${fresh.map((l) => `- ${l}`).join("\n")}\n`;
	mkdirSync(dirname(path), { recursive: true });
	appendFileSync(path, block);
	return fresh.length;
}

interface Candidate {
	scope: Scope;
	line: string;
}

function loadCandidates(paths: ProjectPaths): Candidate[] {
	const out: Candidate[] = [];
	for (const raw of readFileSafe(paths.globalCandidates).split("\n")) {
		const m = raw.match(/^-\s+(.+)$/);
		if (m) out.push({ scope: "global", line: m[1].trim() });
	}
	for (const raw of readFileSafe(paths.projectCandidates).split("\n")) {
		const m = raw.match(/^-\s+(.+)$/);
		if (m) out.push({ scope: "project", line: m[1].trim() });
	}
	return out;
}

function removeCandidatesFromFile(path: string | null, toRemove: Set<string>): void {
	if (!path || toRemove.size === 0) return;
	const current = readFileSafe(path);
	if (!current) return;
	const kept: string[] = [];
	for (const raw of current.split("\n")) {
		const m = raw.match(/^-\s+(.+)$/);
		if (m && toRemove.has(m[1].trim())) continue;
		kept.push(raw);
	}
	const cleaned = kept.join("\n").replace(/\n{3,}/g, "\n\n").trimEnd() + "\n";
	writeFileSync(path, cleaned, "utf-8");
}

function appendToAgentsMd(path: string, lines: string[]): void {
	if (lines.length === 0) return;
	mkdirSync(dirname(path), { recursive: true });
	const existing = readFileSafe(path);
	const entries = lines.map((l) => `- ${l}`).join("\n");
	if (!existing.trim()) {
		writeFileSync(path, `# AGENTS.md\n\n${AGENTS_HEADING}\n\n${entries}\n`, "utf-8");
		return;
	}
	if (existing.includes(AGENTS_HEADING)) {
		const updated = existing.replace(
			new RegExp(`(${AGENTS_HEADING}\\n+)`),
			(_match, header: string) => `${header}${entries}\n\n`,
		);
		writeFileSync(path, updated, "utf-8");
		return;
	}
	const sep = existing.endsWith("\n") ? "" : "\n";
	writeFileSync(path, `${existing}${sep}\n${AGENTS_HEADING}\n\n${entries}\n`, "utf-8");
}

function resolveExtractionModel(): string {
	return process.env.PI_MEMORY_CANDIDATES_MODEL?.trim() || DEFAULT_MODEL;
}

type ExtractionOutcome =
	| { kind: "added"; total: number; global: number; project: number }
	| { kind: "none" }
	| { kind: "skipped"; reason: string }
	| { kind: "failed"; reason: string };

function notifyOutcome(ctx: ExtensionContext | ExtensionCommandContext, outcome: ExtractionOutcome): void {
	if (!ctx.hasUI) return;
	try {
		switch (outcome.kind) {
			case "added":
				ctx.ui.notify(
					`📝 ${outcome.total} memory candidate${outcome.total === 1 ? "" : "s"}` +
						` (${outcome.global}G/${outcome.project}P) — /promote to review`,
					"info",
				);
				break;
			case "none":
				ctx.ui.notify("📝 No new memory candidates", "info");
				break;
			case "skipped":
				ctx.ui.notify(`📝 Skipped: ${outcome.reason}`, "warning");
				break;
			case "failed":
				ctx.ui.notify(`📝 Failed: ${outcome.reason}`, "warning");
				break;
		}
	} catch {
		/* ctx may be stale during shutdown */
	}
}

export default function (pi: ExtensionAPI) {
	let userTurns = 0;
	let turnsSinceReview = 0;
	let reviewInProgress = false;

	pi.on("message_end", async (event) => {
		if (event.message.role === "user") userTurns++;
	});

	async function runExtraction(ctx: ExtensionContext, timeoutMs: number): Promise<ExtractionOutcome> {
		if (reviewInProgress) return { kind: "skipped", reason: "extraction already running" };
		reviewInProgress = true;
		try {
			let entries: unknown[];
			try {
				entries = ctx.sessionManager.getBranch();
			} catch (e) {
				return { kind: "failed", reason: `session unavailable: ${(e as Error).message}` };
			}
			const transcriptParts = collectTranscript(entries);
			if (transcriptParts.length < MIN_TRANSCRIPT_PARTS) {
				return {
					kind: "skipped",
					reason: `transcript has ${transcriptParts.length} message(s), need ≥${MIN_TRANSCRIPT_PARTS}`,
				};
			}
			const transcript = transcriptParts.slice(-RECENT_MESSAGES).join("\n\n");

			const paths = resolveProjectPaths(ctx.cwd);
			const existingCandidates = {
				global: readFileSafe(paths.globalCandidates),
				project: readFileSafe(paths.projectCandidates),
			};
			const existingAgentsMd = {
				global: readFileSafe(GLOBAL_AGENTS_MD),
				project: readFileSafe(paths.projectAgentsMd),
			};
			const prompt = buildExtractionPrompt(transcript, paths, existingCandidates, existingAgentsMd);

			let result: Awaited<ReturnType<typeof pi.exec>>;
			try {
				result = await pi.exec(
					"pi",
					[
						"-p", prompt,
						"--print",
						"--no-session",
						// "--no-extensions",
						// "--no-context-files",
						"--model", resolveExtractionModel(),
					],
					{ signal: undefined, timeout: timeoutMs },
				);
			} catch (e) {
				return { kind: "failed", reason: `pi exec threw: ${(e as Error).message}` };
			}
			if (result.code !== 0) {
				const tail = (result.stderr || result.stdout || "").trim().split("\n").slice(-1)[0] || "";
				return { kind: "failed", reason: `pi exit ${result.code}${tail ? `: ${tail.slice(0, 160)}` : ""}` };
			}
			if (!result.stdout || !result.stdout.trim()) {
				return { kind: "none" };
			}
			const extracted = parseExtraction(result.stdout);
			const seenGlobal = [
				...collectExistingTokenSets(paths.globalCandidates),
				...collectExistingTokenSets(GLOBAL_AGENTS_MD),
			];
			const addedGlobal = appendCandidates(paths.globalCandidates, extracted.global, ctx.cwd, seenGlobal);
			let addedProject = 0;
			if (paths.projectCandidates) {
				const seenProject = [
					...collectExistingTokenSets(paths.projectCandidates),
					...collectExistingTokenSets(paths.projectAgentsMd),
				];
				addedProject = appendCandidates(paths.projectCandidates, extracted.project, ctx.cwd, seenProject);
			}
			const total = addedGlobal + addedProject;
			if (total === 0) return { kind: "none" };
			return { kind: "added", total, global: addedGlobal, project: addedProject };
		} finally {
			reviewInProgress = false;
		}
	}

	pi.on("turn_end", async (_event, ctx) => {
		turnsSinceReview++;
		if (turnsSinceReview < TURN_INTERVAL) return;
		turnsSinceReview = 0;
		if (userTurns < MIN_USER_TURNS) return;
		runExtraction(ctx, REVIEW_TIMEOUT_MS)
			.then((outcome) => {
				if (outcome.kind === "added") notifyOutcome(ctx, outcome);
			})
			.catch(() => {
				/* best-effort */
			});
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		if (userTurns < MIN_USER_TURNS) return;
		runExtraction(ctx, SHUTDOWN_TIMEOUT_MS).catch(() => {
			/* best-effort */
		});
	});

	pi.registerCommand("promote", {
		description: "Review memory candidates and promote them to AGENTS.md",
		handler: async (_args, ctx) => {
			await openPromoteUI(pi, ctx);
		},
	});

	pi.registerCommand("memory-extract", {
		description: "Manually extract memory candidates from the current session",
		handler: async (_args, ctx) => {
			ctx.ui.setStatus("memory-candidates", "📝 Extracting...");
			let outcome: ExtractionOutcome;
			try {
				outcome = await runExtraction(ctx, REVIEW_TIMEOUT_MS);
			} catch (e) {
				outcome = { kind: "failed", reason: (e as Error).message };
			} finally {
				try { ctx.ui.setStatus("memory-candidates", ""); } catch { /* stale */ }
			}
			notifyOutcome(ctx, outcome);
		},
	});
}

interface CandidateRow extends Candidate {
	selected: boolean;
}

type PromoteAction = { action: "promote" | "discard" | "quit"; rows: CandidateRow[] };

class PromoteSelector {
	private rows: CandidateRow[];
	private cursor = 0;
	private cachedWidth?: number;
	private cachedLines?: string[];
	private done: (result: PromoteAction) => void;

	constructor(candidates: Candidate[], done: (result: PromoteAction) => void) {
		this.rows = candidates.map((c) => ({ ...c, selected: false }));
		this.done = done;
	}

	private resolve(action: PromoteAction["action"]): void {
		this.done({ action, rows: this.rows });
	}

	handleInput(data: string): void {
		if (this.rows.length === 0) {
			if (matchesKey(data, Key.escape) || matchesKey(data, "q")) this.resolve("quit");
			return;
		}
		if (matchesKey(data, Key.up) || matchesKey(data, "k")) {
			this.cursor = Math.max(0, this.cursor - 1);
			this.invalidate();
		} else if (matchesKey(data, Key.down) || matchesKey(data, "j")) {
			this.cursor = Math.min(this.rows.length - 1, this.cursor + 1);
			this.invalidate();
		} else if (matchesKey(data, Key.space)) {
			this.rows[this.cursor].selected = !this.rows[this.cursor].selected;
			this.invalidate();
		} else if (matchesKey(data, "a")) {
			const allSelected = this.rows.every((r) => r.selected);
			for (const r of this.rows) r.selected = !allSelected;
			this.invalidate();
		} else if (matchesKey(data, "p") || matchesKey(data, Key.enter)) {
			this.resolve("promote");
		} else if (matchesKey(data, "d")) {
			this.resolve("discard");
		} else if (matchesKey(data, "q") || matchesKey(data, Key.escape) || matchesKey(data, Key.ctrl("c"))) {
			this.resolve("quit");
		}
	}



	render(width: number): string[] {
		if (this.cachedLines && this.cachedWidth === width) return this.cachedLines;
		const lines: string[] = [];
		const header = "Memory candidates — space toggle · a all · p promote · d discard · q quit";
		lines.push(truncateToWidth(header, width));
		lines.push("");
		if (this.rows.length === 0) {
			lines.push(truncateToWidth("  (no candidates)", width));
		} else {
			for (let i = 0; i < this.rows.length; i++) {
				const r = this.rows[i];
				const cursor = i === this.cursor ? ">" : " ";
				const check = r.selected ? "[x]" : "[ ]";
				const tag = r.scope === "global" ? "[G]" : "[P]";
				const text = `${cursor} ${check} ${tag} ${r.line}`;
				lines.push(truncateToWidth(text, width));
			}
		}
		const selected = this.rows.filter((r) => r.selected).length;
		lines.push("");
		lines.push(truncateToWidth(`Selected: ${selected}/${this.rows.length}`, width));
		this.cachedLines = lines;
		this.cachedWidth = width;
		return lines;
	}

	invalidate(): void {
		this.cachedWidth = undefined;
		this.cachedLines = undefined;
	}
}

async function openPromoteUI(pi: ExtensionAPI, ctx: ExtensionCommandContext): Promise<void> {
	const paths = resolveProjectPaths(ctx.cwd);
	const candidates = loadCandidates(paths);
	if (candidates.length === 0) {
		ctx.ui.notify("No memory candidates to review", "info");
		return;
	}

	const result = await ctx.ui.custom<PromoteAction>(
		(_tui, _theme, _kb, done) => new PromoteSelector(candidates, done),
	);

	if (result.action === "quit") return;

	const selected = result.rows.filter((r) => r.selected);
	if (selected.length === 0) {
		ctx.ui.notify("Nothing selected", "info");
		return;
	}

	const globalLines = selected.filter((r) => r.scope === "global").map((r) => r.line);
	const projectLines = selected.filter((r) => r.scope === "project").map((r) => r.line);

	if (result.action === "promote") {
		if (globalLines.length > 0) {
			appendToAgentsMd(GLOBAL_AGENTS_MD, globalLines);
		}
		if (projectLines.length > 0) {
			if (!paths.projectAgentsMd) {
				ctx.ui.notify("Cannot promote project candidates from home dir", "warning");
			} else {
				appendToAgentsMd(paths.projectAgentsMd, projectLines);
			}
		}
	}
	// Both promote and discard remove from candidates files.
	removeCandidatesFromFile(paths.globalCandidates, new Set(globalLines));
	removeCandidatesFromFile(paths.projectCandidates, new Set(projectLines));

	const verb = result.action === "promote" ? "promoted" : "discarded";
	const parts: string[] = [];
	if (globalLines.length > 0) parts.push(`${globalLines.length} → ~/.pi/agent/AGENTS.md`);
	if (projectLines.length > 0 && paths.projectAgentsMd) {
		parts.push(`${projectLines.length} → ${paths.projectAgentsMd}`);
	}
	ctx.ui.notify(`${verb}: ${parts.join(", ")}`, "info");
}
