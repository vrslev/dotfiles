import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { getAgentDir, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { getModels } from "@earendil-works/pi-ai";
import { openaiCodexOAuthProvider } from "@earendil-works/pi-ai/oauth";

const provider = "openai-codex";
const modelsPath = join(getAgentDir(), "models.json");
const requiredInstructions = "You are a helpful assistant.";

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
		compat: { ...(compat ?? {}), supportsLongCacheRetention: false },
	};
});

function cleanPayload(payload: unknown) {
	if (!payload || typeof payload !== "object") {
		return payload;
	}

	const next = {
		...(payload as Record<string, unknown>),
		instructions: requiredInstructions,
	};

	delete next.max_output_tokens;
	delete next.prompt_cache_retention;

	return next;
}

function patchFetch(baseUrl: string) {
	const global = globalThis as unknown as {
		__openaiCodexLiteLLMFetchPatched?: boolean;
		fetch: typeof fetch;
	};
	if (global.__openaiCodexLiteLLMFetchPatched) {
		return;
	}

	const originalFetch = global.fetch.bind(globalThis);
	global.__openaiCodexLiteLLMFetchPatched = true;
	global.fetch = (input, init) => {
		const url = input instanceof Request ? input.url : String(input);
		if (url.startsWith(baseUrl) && typeof init?.body === "string") {
			try {
				init = { ...init, body: JSON.stringify(cleanPayload(JSON.parse(init.body))) };
			} catch {
				return originalFetch(input, init);
			}
		}

		return originalFetch(input, init);
	};
}

export default function (pi: ExtensionAPI) {
	const config = getProviderConfig();
	if (!config) {
		return;
	}

	patchFetch(config.baseUrl);

	pi.registerProvider(provider, {
		baseUrl: config.baseUrl,
		api: "openai-responses",
		headers: config.headers ?? {},
		models,
		oauth: openaiCodexOAuthProvider,
	});

	pi.on("before_provider_request", (event, ctx) => {
		if (ctx.model?.provider !== provider) {
			return;
		}

		return cleanPayload(event.payload);
	});
}
