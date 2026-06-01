import { readFileSync } from "node:fs";
import { join } from "node:path";
import { getAgentDir, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { getModels, type Model, type SimpleStreamOptions } from "@earendil-works/pi-ai";
import { streamSimpleOpenAIResponses } from "/Users/ruavel3/.pi/agent/npm/node_modules/@earendil-works/pi-ai/dist/providers/openai-responses.js";
import { openaiCodexOAuthProvider } from "/Users/ruavel3/.pi/agent/npm/node_modules/@earendil-works/pi-ai/dist/oauth.js";

const provider = "openai-codex";
const modelsPath = join(getAgentDir(), "models.json");

const config =
	JSON.parse(readFileSync(modelsPath, "utf-8")).providers?.[provider] ?? {};

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

	return item.role === "developer" || item.role === "system";
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
			const next = {
				...payload,
				input: cleanInput(payload.input),
				instructions: context.systemPrompt,
			};

			delete next.max_output_tokens;
			delete next.prompt_cache_key;
			delete next.prompt_cache_retention;

			return next;
		},
	} as any);
}

export default function (pi: ExtensionAPI) {
	pi.registerProvider(provider, {
		baseUrl: config.baseUrl,
		api: "openai-responses",
		headers: config.headers ?? {},
		models,
		oauth: openaiCodexOAuthProvider,
		streamSimple: stream,
	});
}
