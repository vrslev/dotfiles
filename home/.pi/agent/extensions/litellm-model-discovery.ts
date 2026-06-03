import { execSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { getModels, getProviders, type Api, type KnownProvider, type Model } from "@earendil-works/pi-ai";
import { getAgentDir, type ExtensionAPI, type ProviderModelConfig } from "@earendil-works/pi-coding-agent";

type ModelOverride = {
	name?: string;
	reasoning?: boolean;
	thinkingLevelMap?: ProviderModelConfig["thinkingLevelMap"];
	input?: ProviderModelConfig["input"];
	cost?: Partial<ProviderModelConfig["cost"]>;
	contextWindow?: number;
	maxTokens?: number;
	headers?: Record<string, string>;
	compat?: ProviderModelConfig["compat"];
};

type ModelsConfig = {
	providers?: Record<string, LiteLLMProviderConfig>;
};

type LiteLLMProviderConfig = {
	name?: string;
	baseUrl?: string;
	apiKey?: string;
	api?: string;
	headers?: Record<string, string>;
	authHeader?: boolean;
	compat?: ProviderModelConfig["compat"];
	models?: ProviderModelConfig[];
	modelOverrides?: Record<string, ModelOverride>;
	"litellm-provider"?: boolean;
};

type LiteLLMModel = {
	id?: unknown;
	name?: unknown;
	owned_by?: unknown;
	context_window?: unknown;
	max_tokens?: unknown;
};

type LiteLLMModelsResponse = {
	data?: LiteLLMModel[];
};

type LiteLLMModelInfoEntry = {
	model_name?: unknown;
	model_info?: {
		mode?: unknown;
		input_cost_per_token?: unknown;
		output_cost_per_token?: unknown;
		cache_read_input_token_cost?: unknown;
		cache_creation_input_token_cost?: unknown;
		max_input_tokens?: unknown;
		max_output_tokens?: unknown;
		supports_reasoning?: unknown;
		supports_vision?: unknown;
	};
};

type LiteLLMModelInfoResponse = {
	data?: LiteLLMModelInfoEntry[];
};

const modelsPath = join(getAgentDir(), "models.json");
const timeoutMs = 10_000;
const defaultCost = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 };
const knownProviderSet = new Set<string>(getProviders());
const anthropicModelPattern = /(?:^|[-_/.:])(?:anthropic\/|(?:claude|opus|sonnet|haiku)(?=$|[-_/.:]))/i;
const moonshotModelPattern = /^(moonshotai\/|moonshot\/|kimi[-/])/i;
const forcedThinkingModelPattern = /(?:^|[-/])thinking(?:[-/]|$)/i;

function readModelsConfig(): ModelsConfig {
	return JSON.parse(readFileSync(modelsPath, "utf-8")) as ModelsConfig;
}

function normalizeBaseUrl(baseUrl: string): string {
	return baseUrl.replace(/\/+$/, "").replace(/\/v1\/?$/i, "");
}

function resolveCommand(value: string): string | undefined {
	const output = execSync(value.slice(1), {
		encoding: "utf-8",
		stdio: ["ignore", "pipe", "ignore"],
		shell: true,
	}).trim();
	return output || undefined;
}

function readEnv(name: string): string | undefined {
	const value = process.env[name];
	return value === undefined ? undefined : value;
}

function resolveConfigValue(value: string): string | undefined {
	if (value.startsWith("!")) {
		return resolveCommand(value);
	}

	let output = "";
	for (let index = 0; index < value.length; index++) {
		const char = value[index];
		if (char !== "$") {
			output += char;
			continue;
		}

		const next = value[index + 1];
		if (next === "$") {
			output += "$";
			index++;
			continue;
		}
		if (next === "!") {
			output += "!";
			index++;
			continue;
		}
		if (next === "{") {
			const end = value.indexOf("}", index + 2);
			if (end === -1) return undefined;
			const envName = value.slice(index + 2, end);
			const envValue = readEnv(envName);
			if (envValue === undefined) return undefined;
			output += envValue;
			index = end;
			continue;
		}

		const match = value.slice(index + 1).match(/^[A-Za-z_][A-Za-z0-9_]*/);
		if (!match) {
			output += "$";
			continue;
		}

		const envValue = readEnv(match[0]);
		if (envValue === undefined) return undefined;
		output += envValue;
		index += match[0].length;
	}

	return output;
}

function withTimeout(signalMs: number): { signal: AbortSignal; cancel: () => void } {
	const controller = new AbortController();
	const timer = setTimeout(() => controller.abort(new Error(`Timed out after ${signalMs}ms`)), signalMs);
	return {
		signal: controller.signal,
		cancel: () => clearTimeout(timer),
	};
}

async function fetchJson<T>(url: string, apiKey: string): Promise<{ ok: true; data: T } | { ok: false; status: number }> {
	const { signal, cancel } = withTimeout(timeoutMs);
	try {
		const response = await fetch(url, {
			headers: { Authorization: `Bearer ${apiKey}`, Accept: "application/json" },
			signal,
		});
		if (!response.ok) return { ok: false, status: response.status };
		return { ok: true, data: (await response.json()) as T };
	} finally {
		cancel();
	}
}

async function fetchModels(baseUrl: string, apiKey: string): Promise<LiteLLMModel[]> {
	const result = await fetchJson<LiteLLMModelsResponse>(`${normalizeBaseUrl(baseUrl)}/v1/models`, apiKey);
	if (!result.ok) throw new Error(`/v1/models returned ${result.status}`);
	return result.data.data ?? [];
}

function infoScore(entry: LiteLLMModelInfoEntry): number {
	const info = entry.model_info;
	if (!info) return 0;
	return [
		info.input_cost_per_token,
		info.output_cost_per_token,
		info.cache_read_input_token_cost,
		info.cache_creation_input_token_cost,
		info.max_input_tokens,
		info.max_output_tokens,
		info.supports_reasoning,
		info.supports_vision,
	].filter((value) => value !== undefined).length;
}

async function fetchModelInfo(baseUrl: string, apiKey: string): Promise<Map<string, LiteLLMModelInfoEntry>> {
	const result = await fetchJson<LiteLLMModelInfoResponse>(`${normalizeBaseUrl(baseUrl)}/model/info`, apiKey);
	if (!result.ok) return new Map();

	const entries = new Map<string, LiteLLMModelInfoEntry>();
	for (const entry of result.data.data ?? []) {
		const id = stringOrUndefined(entry.model_name);
		if (!id) continue;
		if (entry.model_info?.mode !== undefined && entry.model_info.mode !== "chat") continue;
		const existing = entries.get(id);
		if (!existing || infoScore(entry) > infoScore(existing)) {
			entries.set(id, entry);
		}
	}
	return entries;
}

function numberOrUndefined(value: unknown): number | undefined {
	return typeof value === "number" && Number.isFinite(value) ? value : undefined;
}

function booleanOrUndefined(value: unknown): boolean | undefined {
	return typeof value === "boolean" ? value : undefined;
}

function stringOrUndefined(value: unknown): string | undefined {
	return typeof value === "string" && value.length > 0 ? value : undefined;
}

function toKnownProvider(provider: string | undefined): KnownProvider | undefined {
	if (!provider) return undefined;
	const normalized = provider.toLowerCase();
	return knownProviderSet.has(normalized) ? (normalized as KnownProvider) : undefined;
}

function findCatalogModel(id: string, ownedBy?: string): Model<Api> | undefined {
	const prefixProvider = toKnownProvider(id.split("/")[0]);
	const candidates = [toKnownProvider(ownedBy), prefixProvider].filter(
		(provider): provider is KnownProvider => provider !== undefined,
	);

	for (const provider of candidates) {
		const exact = getModels(provider).find((model) => model.id === id);
		if (exact) return exact;
		const providerQualified = getModels(provider).find((model) => model.id === `${provider}/${id}`);
		if (providerQualified) return providerQualified;
	}

	for (const provider of getProviders()) {
		const exact = getModels(provider).find((model) => model.id === id);
		if (exact) return exact;
	}

	return undefined;
}

function buildCompat(modelId: string): ProviderModelConfig["compat"] {
	if (moonshotModelPattern.test(modelId)) {
		return {
			supportsStore: false,
			supportsDeveloperRole: false,
			supportsReasoningEffort: false,
			supportsStrictMode: false,
			maxTokensField: "max_tokens",
		};
	}
	if (anthropicModelPattern.test(modelId)) {
		return { supportsStore: false, cacheControlFormat: "anthropic" };
	}
	return { supportsStore: false };
}

function isVisionAlias(id: string): boolean {
	return /(?:^|[-_/.:])(?:vlm|vision|image|gemini|claude|gpt-5)(?=$|[-_/.:])/i.test(id);
}

function hasForcedThinkingAlias(id: string): boolean {
	return forcedThinkingModelPattern.test(id) || /(?:^|[-_/.:])(?:gpt-5|claude|opus|sonnet|deepseek-v\d|glm-5|kimi-k2)(?=$|[-_/.:])/i.test(id);
}

function costFromInfo(info: LiteLLMModelInfoEntry["model_info"]): ProviderModelConfig["cost"] | undefined {
	if (!info) return undefined;
	const input = numberOrUndefined(info.input_cost_per_token);
	const output = numberOrUndefined(info.output_cost_per_token);
	const cacheRead = numberOrUndefined(info.cache_read_input_token_cost);
	const cacheWrite = numberOrUndefined(info.cache_creation_input_token_cost);
	if (input === undefined && output === undefined && cacheRead === undefined && cacheWrite === undefined) return undefined;
	return {
		input: (input ?? 0) * 1_000_000,
		output: (output ?? 0) * 1_000_000,
		cacheRead: (cacheRead ?? 0) * 1_000_000,
		cacheWrite: (cacheWrite ?? 0) * 1_000_000,
	};
}

function mergeCost(
	baseCost: ProviderModelConfig["cost"],
	overrideCost: ModelOverride["cost"] | undefined,
): ProviderModelConfig["cost"] {
	return {
		input: overrideCost?.input ?? baseCost.input,
		output: overrideCost?.output ?? baseCost.output,
		cacheRead: overrideCost?.cacheRead ?? baseCost.cacheRead,
		cacheWrite: overrideCost?.cacheWrite ?? baseCost.cacheWrite,
	};
}

function mergeCompat(
	baseCompat: ProviderModelConfig["compat"] | undefined,
	overrideCompat: ProviderModelConfig["compat"] | undefined,
): ProviderModelConfig["compat"] {
	return { ...baseCompat, ...overrideCompat };
}

function applyOverride(model: ProviderModelConfig, override: ModelOverride | undefined): ProviderModelConfig {
	if (!override) return model;
	return {
		...model,
		name: override.name ?? model.name,
		reasoning: override.reasoning ?? model.reasoning,
		thinkingLevelMap: override.thinkingLevelMap ?? model.thinkingLevelMap,
		input: override.input ?? model.input,
		cost: mergeCost(model.cost, override.cost),
		contextWindow: override.contextWindow ?? model.contextWindow,
		maxTokens: override.maxTokens ?? model.maxTokens,
		headers: override.headers ?? model.headers,
		compat: mergeCompat(model.compat, override.compat),
	};
}

function getOverrides(providerConfig: LiteLLMProviderConfig): Map<string, ModelOverride> {
	const overrides = new Map<string, ModelOverride>();
	for (const [id, override] of Object.entries(providerConfig.modelOverrides ?? {})) {
		overrides.set(id, override);
	}
	for (const model of providerConfig.models ?? []) {
		overrides.set(model.id, {
			name: model.name,
			reasoning: model.reasoning,
			thinkingLevelMap: model.thinkingLevelMap,
			input: model.input,
			cost: model.cost,
			contextWindow: model.contextWindow,
			maxTokens: model.maxTokens,
			headers: model.headers,
			compat: model.compat,
		});
	}
	return overrides;
}

function toProviderModels(
	providerConfig: LiteLLMProviderConfig,
	remoteModels: LiteLLMModel[],
	modelInfo: Map<string, LiteLLMModelInfoEntry>,
): ProviderModelConfig[] {
	const overrides = getOverrides(providerConfig);
	const seen = new Set<string>();
	const models: ProviderModelConfig[] = [];

	for (const remoteModel of remoteModels) {
		const id = stringOrUndefined(remoteModel.id);
		if (!id || seen.has(id)) continue;
		seen.add(id);

		const ownedBy = stringOrUndefined(remoteModel.owned_by);
		const catalogModel = findCatalogModel(id, ownedBy);
		const info = modelInfo.get(id)?.model_info;
		const baseModel: ProviderModelConfig = {
			id,
			name: stringOrUndefined(remoteModel.name) ?? catalogModel?.name ?? id,
			reasoning: booleanOrUndefined(info?.supports_reasoning) ?? catalogModel?.reasoning ?? hasForcedThinkingAlias(id),
			thinkingLevelMap: catalogModel?.thinkingLevelMap,
			input: booleanOrUndefined(info?.supports_vision)
				? ["text", "image"]
				: catalogModel?.input ?? (isVisionAlias(id) ? ["text", "image"] : ["text"]),
			cost: costFromInfo(info) ?? catalogModel?.cost ?? defaultCost,
			contextWindow:
				numberOrUndefined(info?.max_input_tokens) ??
				numberOrUndefined(remoteModel.context_window) ??
				catalogModel?.contextWindow ??
				128_000,
			maxTokens:
				numberOrUndefined(info?.max_output_tokens) ?? numberOrUndefined(remoteModel.max_tokens) ?? catalogModel?.maxTokens ?? 16_384,
			compat: mergeCompat(buildCompat(id), providerConfig.compat),
		};
		models.push(applyOverride(baseModel, overrides.get(id)));
	}

	return models;
}

async function registerProvider(
	pi: ExtensionAPI,
	providerName: string,
	providerConfig: LiteLLMProviderConfig,
): Promise<void> {
	if (!providerConfig.baseUrl) return;
	if (!providerConfig.apiKey) return;

	const baseUrl = resolveConfigValue(providerConfig.baseUrl);
	const apiKey = resolveConfigValue(providerConfig.apiKey);
	if (!baseUrl || !apiKey) return;

	try {
		const [remoteModels, modelInfo] = await Promise.all([fetchModels(baseUrl, apiKey), fetchModelInfo(baseUrl, apiKey)]);
		const models = toProviderModels(providerConfig, remoteModels, modelInfo);
		if (models.length === 0) return;

		pi.registerProvider(providerName, {
			name: providerConfig.name,
			baseUrl: `${normalizeBaseUrl(baseUrl)}/v1`,
			apiKey: providerConfig.apiKey,
			api: providerConfig.api ?? "openai-completions",
			headers: providerConfig.headers,
			authHeader: providerConfig.authHeader,
			compat: providerConfig.compat,
			models,
		});

	} catch {}
}

export default async function litellmModelDiscovery(pi: ExtensionAPI): Promise<void> {
	const config = readModelsConfig();
	const providers = Object.entries(config.providers ?? {}).filter((entry) => entry[1]["litellm-provider"] === true);
	await Promise.all(providers.map(([providerName, providerConfig]) => registerProvider(pi, providerName, providerConfig)));
}
