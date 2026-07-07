import { createHash } from "node:crypto";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { getModels, getProviders, type Api, type KnownProvider, type Model } from "@earendil-works/pi-ai";
import {
	AuthStorage,
	getAgentDir,
	ModelRegistry,
	type ExtensionAPI,
	type ProviderConfig,
	type ProviderModelConfig,
} from "@earendil-works/pi-coding-agent";

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

type LiteLLMProviderConfig = Omit<ProviderConfig, "models" | "oauth" | "streamSimple"> & {
	modelOverrides?: Record<string, ModelOverride>;
	"litellm-provider"?: boolean;
};

type ModelsConfig = {
	providers?: Record<string, LiteLLMProviderConfig>;
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

type LiteLLMModelInfo = {
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

type LiteLLMModelInfoEntry = {
	model_name?: unknown;
	model_info?: LiteLLMModelInfo;
};

type LiteLLMModelInfoResponse = {
	data?: LiteLLMModelInfoEntry[];
};

type ModelInfoMetadata = {
	reasoning?: boolean;
	input?: ProviderModelConfig["input"];
	cost?: ProviderModelConfig["cost"];
	contextWindow?: number;
	maxTokens?: number;
};

type ProviderEntry = [string, LiteLLMProviderConfig];

type CachedProviderModels = {
	baseUrl: string;
	apiKeyFingerprint?: string;
	fetchedAt: number;
	models: ProviderModelConfig[];
};

type ModelsCache = {
	version: 1;
	providers: Record<string, CachedProviderModels>;
};

const agentDir = getAgentDir();
const modelsPath = join(agentDir, "models.json");
const cachePath = join(agentDir, "cache", "litellm-model-discovery.json");
const modelRegistry = ModelRegistry.create(AuthStorage.create(), modelsPath);
const knownProviderSet = new Set<string>(getProviders());
const defaultCost = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 };
const defaultCompat: ProviderModelConfig["compat"] = { supportsStore: false };
const defaultContextWindow = 128_000;
const defaultMaxTokens = 16_384;
const modelListTimeoutMs = 5_000;
const modelInfoTimeoutMs = 2_000;

let refreshInFlight: Promise<void> | undefined;

function normalizeBaseUrl(baseUrl: string): string {
	return baseUrl.replace(/\/+$/, "").replace(/\/v1\/?$/i, "");
}

function readModelsConfig(): ModelsConfig {
	if (!existsSync(modelsPath)) return {};
	return JSON.parse(readFileSync(modelsPath, "utf-8")) as ModelsConfig;
}

function getLiteLLMProviders(): ProviderEntry[] {
	return Object.entries(readModelsConfig().providers ?? {}).filter((entry): entry is ProviderEntry => entry[1]["litellm-provider"] === true);
}

function stringValue(value: unknown): string | undefined {
	return typeof value === "string" && value.length > 0 ? value : undefined;
}

function numberValue(value: unknown): number | undefined {
	return typeof value === "number" && Number.isFinite(value) ? value : undefined;
}

function booleanValue(value: unknown): boolean | undefined {
	return typeof value === "boolean" ? value : undefined;
}

function minValue(left: number | undefined, right: number | undefined): number | undefined {
	if (left === undefined) return right;
	if (right === undefined) return left;
	return Math.min(left, right);
}

function andValue(left: boolean | undefined, right: boolean | undefined): boolean | undefined {
	if (left === undefined) return right;
	if (right === undefined) return left;
	return left && right;
}

function toKnownProvider(value: string | undefined): KnownProvider | undefined {
	const normalized = value?.toLowerCase();
	return normalized && knownProviderSet.has(normalized) ? (normalized as KnownProvider) : undefined;
}

function findCatalogModel(id: string, ownedBy: string | undefined): Model<Api> | undefined {
	const prefixProvider = toKnownProvider(id.split("/")[0]);
	const providers = [toKnownProvider(ownedBy), prefixProvider].filter((provider): provider is KnownProvider => !!provider);

	for (const provider of providers) {
		const models = getModels(provider);
		const exact = models.find((model) => model.id === id);
		if (exact) return exact;
		const unqualified = id.slice(provider.length + 1);
		const prefixed = models.find((model) => model.id === unqualified);
		if (id.startsWith(`${provider}/`) && prefixed) return prefixed;
	}

	for (const provider of getProviders()) {
		const exact = getModels(provider).find((model) => model.id === id);
		if (exact) return exact;
	}

	return undefined;
}

function mergeCost(
	base: ProviderModelConfig["cost"],
	override: ModelOverride["cost"] | undefined,
): ProviderModelConfig["cost"] {
	return {
		input: override?.input ?? base.input,
		output: override?.output ?? base.output,
		cacheRead: override?.cacheRead ?? base.cacheRead,
		cacheWrite: override?.cacheWrite ?? base.cacheWrite,
	};
}

function mergeCompat(
	base: ProviderModelConfig["compat"] | undefined,
	override: ProviderModelConfig["compat"] | undefined,
): ProviderModelConfig["compat"] {
	return { ...base, ...override };
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

function fallbackReasoning(id: string): boolean {
	return /(?:^|[-_/])thinking(?:[-_/]|$)/i.test(id);
}

function fallbackInput(id: string): ProviderModelConfig["input"] {
	return /(?:^|[-_/])(image|vision|vlm)(?:[-_/]|$)/i.test(id) ? ["text", "image"] : ["text"];
}

function costFromInfo(info: LiteLLMModelInfo): ProviderModelConfig["cost"] | undefined {
	const input = numberValue(info.input_cost_per_token);
	const output = numberValue(info.output_cost_per_token);
	const cacheRead = numberValue(info.cache_read_input_token_cost);
	const cacheWrite = numberValue(info.cache_creation_input_token_cost);
	if (input === undefined && output === undefined && cacheRead === undefined && cacheWrite === undefined) return undefined;
	return {
		input: (input ?? 0) * 1_000_000,
		output: (output ?? 0) * 1_000_000,
		cacheRead: (cacheRead ?? 0) * 1_000_000,
		cacheWrite: (cacheWrite ?? 0) * 1_000_000,
	};
}

function metadataFromInfo(info: LiteLLMModelInfo): ModelInfoMetadata {
	const supportsVision = booleanValue(info.supports_vision);
	return {
		reasoning: booleanValue(info.supports_reasoning),
		input: supportsVision === undefined ? undefined : supportsVision ? ["text", "image"] : ["text"],
		cost: costFromInfo(info),
		contextWindow: numberValue(info.max_input_tokens),
		maxTokens: numberValue(info.max_output_tokens),
	};
}

function mergeMetadata(base: ModelInfoMetadata, next: ModelInfoMetadata): ModelInfoMetadata {
	return {
		reasoning: andValue(base.reasoning, next.reasoning),
		input: base.input?.includes("image") && next.input?.includes("image") ? ["text", "image"] : base.input ?? next.input,
		cost: base.cost ?? next.cost,
		contextWindow: minValue(base.contextWindow, next.contextWindow),
		maxTokens: minValue(base.maxTokens, next.maxTokens),
	};
}

async function fetchJson<T>(url: string, apiKey: string, timeoutMs: number): Promise<T | undefined> {
	try {
		const response = await fetch(url, {
			headers: { Authorization: `Bearer ${apiKey}`, Accept: "application/json" },
			signal: AbortSignal.timeout(timeoutMs),
		});
		return response.ok ? ((await response.json()) as T) : undefined;
	} catch {
		return undefined;
	}
}

async function fetchModels(baseUrl: string, apiKey: string): Promise<LiteLLMModel[]> {
	const payload = await fetchJson<LiteLLMModelsResponse>(`${normalizeBaseUrl(baseUrl)}/v1/models`, apiKey, modelListTimeoutMs);
	return payload?.data ?? [];
}

async function fetchModelInfo(baseUrl: string, apiKey: string): Promise<Map<string, ModelInfoMetadata>> {
	const payload = await fetchJson<LiteLLMModelInfoResponse>(`${normalizeBaseUrl(baseUrl)}/model/info`, apiKey, modelInfoTimeoutMs);
	const metadata = new Map<string, ModelInfoMetadata>();

	for (const entry of payload?.data ?? []) {
		const id = stringValue(entry.model_name);
		if (!id || !entry.model_info) continue;
		if (entry.model_info.mode !== undefined && entry.model_info.mode !== "chat") continue;

		const next = metadataFromInfo(entry.model_info);
		metadata.set(id, metadata.has(id) ? mergeMetadata(metadata.get(id)!, next) : next);
	}

	return metadata;
}

function toProviderModel(
	remoteModel: LiteLLMModel,
	providerConfig: LiteLLMProviderConfig,
	modelInfo: Map<string, ModelInfoMetadata>,
): ProviderModelConfig | undefined {
	const id = stringValue(remoteModel.id);
	if (!id) return undefined;

	const catalogModel = findCatalogModel(id, stringValue(remoteModel.owned_by));
	const metadata = modelInfo.get(id);
	const model: ProviderModelConfig = {
		id,
		name: stringValue(remoteModel.name) ?? catalogModel?.name ?? id,
		reasoning: metadata?.reasoning ?? catalogModel?.reasoning ?? fallbackReasoning(id),
		thinkingLevelMap: catalogModel?.thinkingLevelMap,
		input: metadata?.input ?? catalogModel?.input ?? fallbackInput(id),
		cost: metadata?.cost ?? catalogModel?.cost ?? defaultCost,
		contextWindow: metadata?.contextWindow ?? numberValue(remoteModel.context_window) ?? catalogModel?.contextWindow ?? defaultContextWindow,
		maxTokens: metadata?.maxTokens ?? numberValue(remoteModel.max_tokens) ?? catalogModel?.maxTokens ?? defaultMaxTokens,
		compat: mergeCompat(mergeCompat(defaultCompat, catalogModel?.compat), providerConfig.compat),
	};
	return applyOverride(model, providerConfig.modelOverrides?.[id]);
}

function dedupeModels(models: ProviderModelConfig[]): ProviderModelConfig[] {
	const seen = new Set<string>();
	return models.filter((model) => {
		if (seen.has(model.id)) return false;
		seen.add(model.id);
		return true;
	});
}

function toProviderModels(
	remoteModels: LiteLLMModel[],
	providerConfig: LiteLLMProviderConfig,
	modelInfo = new Map<string, ModelInfoMetadata>(),
): ProviderModelConfig[] {
	return dedupeModels(
		remoteModels
			.map((model) => toProviderModel(model, providerConfig, modelInfo))
			.filter((model): model is ProviderModelConfig => !!model),
	);
}

function isOfflineModeEnabled(): boolean {
	const value = process.env.PI_OFFLINE;
	return value === "1" || value?.toLowerCase() === "true" || value?.toLowerCase() === "yes";
}

function resolveEnvReference(value: string | undefined): string | undefined {
	if (!value) return undefined;
	const bare = value.match(/^\$([A-Za-z_][A-Za-z0-9_]*)$/);
	if (bare) return process.env[bare[1]];
	const braced = value.match(/^\$\{([A-Za-z_][A-Za-z0-9_]*)\}$/);
	if (braced) return process.env[braced[1]];
	return value;
}

function fingerprintApiKey(apiKey: string | undefined): string | undefined {
	return apiKey ? createHash("sha256").update(apiKey).digest("hex") : undefined;
}

function currentApiKeyFingerprint(providerConfig: LiteLLMProviderConfig): string | undefined {
	return fingerprintApiKey(resolveEnvReference(providerConfig.apiKey));
}

function readModelsCache(): ModelsCache {
	try {
		if (!existsSync(cachePath)) return { version: 1, providers: {} };
		const cache = JSON.parse(readFileSync(cachePath, "utf-8")) as Partial<ModelsCache>;
		return cache.version === 1 && cache.providers ? (cache as ModelsCache) : { version: 1, providers: {} };
	} catch {
		return { version: 1, providers: {} };
	}
}

function isProviderModelConfig(value: unknown): value is ProviderModelConfig {
	if (!value || typeof value !== "object") return false;
	const model = value as Partial<ProviderModelConfig>;
	return (
		typeof model.id === "string" &&
		typeof model.name === "string" &&
		typeof model.reasoning === "boolean" &&
		Array.isArray(model.input) &&
		typeof model.contextWindow === "number" &&
		typeof model.maxTokens === "number" &&
		!!model.cost &&
		typeof model.cost.input === "number" &&
		typeof model.cost.output === "number" &&
		typeof model.cost.cacheRead === "number" &&
		typeof model.cost.cacheWrite === "number"
	);
}

function getCachedModels(providerName: string, providerConfig: LiteLLMProviderConfig): ProviderModelConfig[] {
	if (!providerConfig.baseUrl) return [];
	const cached = readModelsCache().providers[providerName];
	if (!cached) return [];
	if (normalizeBaseUrl(cached.baseUrl) !== normalizeBaseUrl(providerConfig.baseUrl)) return [];
	const currentFingerprint = currentApiKeyFingerprint(providerConfig);
	if (currentFingerprint && cached.apiKeyFingerprint && currentFingerprint !== cached.apiKeyFingerprint) return [];
	return cached.models.filter(isProviderModelConfig);
}

function writeCachedModels(
	providerName: string,
	providerConfig: LiteLLMProviderConfig,
	models: ProviderModelConfig[],
	apiKey: string | undefined,
): void {
	if (!providerConfig.baseUrl || models.length === 0) return;
	try {
		const cache = readModelsCache();
		cache.providers[providerName] = {
			baseUrl: providerConfig.baseUrl,
			apiKeyFingerprint: fingerprintApiKey(apiKey) ?? currentApiKeyFingerprint(providerConfig),
			fetchedAt: Date.now(),
			models,
		};
		mkdirSync(dirname(cachePath), { recursive: true, mode: 0o700 });
		writeFileSync(cachePath, JSON.stringify(cache, null, 2));
	} catch {}
}

function registerProviderModels(
	pi: ExtensionAPI,
	providerName: string,
	providerConfig: LiteLLMProviderConfig,
	models: ProviderModelConfig[],
	apiKey: string | undefined,
): boolean {
	if (!providerConfig.baseUrl || models.length === 0) return false;
	const resolvedApiKey = providerConfig.apiKey ?? apiKey;
	if (!resolvedApiKey) return false;

	pi.registerProvider(providerName, {
		name: providerConfig.name,
		baseUrl: `${normalizeBaseUrl(providerConfig.baseUrl)}/v1`,
		apiKey: resolvedApiKey,
		api: providerConfig.api ?? "openai-completions",
		headers: providerConfig.headers,
		authHeader: providerConfig.authHeader,
		models,
	});
	return true;
}

function registerCachedProvider(pi: ExtensionAPI, providerName: string, providerConfig: LiteLLMProviderConfig): void {
	try {
		registerProviderModels(pi, providerName, providerConfig, getCachedModels(providerName, providerConfig), undefined);
	} catch {}
}

async function refreshProvider(
	pi: ExtensionAPI,
	providerName: string,
	providerConfig: LiteLLMProviderConfig,
): Promise<void> {
	if (!providerConfig.baseUrl) return;

	try {
		const apiKey = await modelRegistry.getApiKeyForProvider(providerName);
		if (!apiKey) return;

		const remoteModels = await fetchModels(providerConfig.baseUrl, apiKey);
		const fastModels = toProviderModels(remoteModels, providerConfig);
		if (!registerProviderModels(pi, providerName, providerConfig, fastModels, apiKey)) return;
		writeCachedModels(providerName, providerConfig, fastModels, apiKey);

		const modelInfo = await fetchModelInfo(providerConfig.baseUrl, apiKey);
		if (modelInfo.size === 0) return;

		const enrichedModels = toProviderModels(remoteModels, providerConfig, modelInfo);
		if (!registerProviderModels(pi, providerName, providerConfig, enrichedModels, apiKey)) return;
		writeCachedModels(providerName, providerConfig, enrichedModels, apiKey);
	} catch {}
}

function refreshProvidersInBackground(pi: ExtensionAPI, providers: ProviderEntry[]): void {
	if (isOfflineModeEnabled() || refreshInFlight || providers.length === 0) return;
	refreshInFlight = Promise.all(providers.map(([providerName, providerConfig]) => refreshProvider(pi, providerName, providerConfig)))
		.then(() => undefined)
		.finally(() => {
			refreshInFlight = undefined;
		});
}

export default function litellmModelDiscovery(pi: ExtensionAPI): void {
	const providers = getLiteLLMProviders();
	for (const [providerName, providerConfig] of providers) {
		registerCachedProvider(pi, providerName, providerConfig);
	}

	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;
		refreshProvidersInBackground(pi, providers);
	});
}
