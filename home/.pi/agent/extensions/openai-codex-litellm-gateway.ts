import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { getAgentDir, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
	getModels,
	streamSimpleOpenAIResponses,
	type Model,
	type SimpleStreamOptions,
} from "@earendil-works/pi-ai";
import { openaiCodexOAuthProvider } from "@earendil-works/pi-ai/oauth";

const provider = "openai-codex";
const modelsPath = join(getAgentDir(), "models.json");
const cacheDebug = process.env.PI_CODEX_CACHE_DEBUG === "1";

type ProviderConfig = {
	baseUrl: string;
	headers?: Record<string, string>;
};

function getProviderConfig(): ProviderConfig | undefined {
	if (!existsSync(modelsPath)) {
		return undefined;
	}

	const parsed = JSON.parse(readFileSync(modelsPath, "utf-8")) as {
		providers?: Record<string, Partial<ProviderConfig>>;
	};
	const config = parsed.providers?.[provider];
	if (!config?.baseUrl) {
		return undefined;
	}

	return { ...config, baseUrl: config.baseUrl };
}

const models = getModels(provider).map((model) => {
	const {
		id,
		name,
		reasoning,
		thinkingLevelMap,
		input,
		cost,
		contextWindow,
		maxTokens,
		compat,
	} = model;

	return {
		id,
		name,
		reasoning,
		thinkingLevelMap,
		input,
		cost,
		contextWindow,
		maxTokens,
		compat,
	};
});

function isSystemMessage(item: unknown) {
	if (!item || typeof item !== "object" || !("role" in item)) {
		return false;
	}

	return item.role === "system";
}

function cleanInput(input: unknown) {
	if (!Array.isArray(input)) {
		return input;
	}

	return input.filter((item) => !isSystemMessage(item));
}

function stream(
	model: Model<any>,
	context: { systemPrompt?: string },
	options?: SimpleStreamOptions,
) {
	return streamSimpleOpenAIResponses(model as any, context as any, {
		...(options as any),
		onPayload: async (payload: Record<string, unknown>) => {
			if (cacheDebug) {
				process.stderr.write(
					`openai-codex-cache: key=${String(payload.prompt_cache_key)} retention=${String(payload.prompt_cache_retention)}\n`,
				);
			}

			const next = {
				...payload,
				input: cleanInput(payload.input),
				instructions: context.systemPrompt,
			};

			delete next.max_output_tokens;
			delete next.prompt_cache_retention;

			return next;
		},
	} as any);
}

export default function (pi: ExtensionAPI) {
	const config = getProviderConfig();
	if (!config) {
		return;
	}

	pi.registerProvider(provider, {
		baseUrl: config.baseUrl,
		api: "openai-responses",
		headers: config.headers ?? {},
		models,
		oauth: openaiCodexOAuthProvider,
		streamSimple: stream,
	});
}
