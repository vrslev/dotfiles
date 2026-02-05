/**
 * Fallback Models Extension
 *
 * Automatically cancels slow requests and retries with a faster model.
 *
 * Configuration in ~/.pi/agent/settings.json or .pi/settings.json:
 *
 * {
 *   "fallbackModels": {
 *     "timeoutMs": 15000,
 *     "fallback-models": {
 *       "anthropic:claude-sonnet-4-20250514": ["anthropic:claude-haiku", "anthropic:claude-sonnet-3.5"],
 *       "openai:gpt-4o": ["openai:gpt-3.5-turbo", "openai:gpt-4"],
 *       "google:gemini-2.0-flash": ["google:gemini-1.5-pro", "google:gemini-1.5-flash"]
 *     }
 *   }
 * }
 */

import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

export default function fallbackModelsExtension(pi: ExtensionAPI) {
	// Default configuration
	const DEFAULT_TIMEOUT_MS = 15000; // 15 seconds

	// State
	let timerId: NodeJS.Timeout | null = null;
	let hasSwitched = false;

	// Load configuration from settings
	function loadConfig(ctx: ExtensionContext) {
		try {
			// Try to get settings from context
			const settings = (ctx as any).settings || {};
			const fallbackModelsConfig = settings.fallbackModels || {};

			return {
				timeoutMs: fallbackModelsConfig.timeoutMs || DEFAULT_TIMEOUT_MS,
				fallbackModels: fallbackModelsConfig["fallback-models"] || {}
			};
		} catch (error) {
			console.error("Fallback Models: Error loading config, using defaults", error);
			return {
				timeoutMs: DEFAULT_TIMEOUT_MS,
				fallbackModels: {}
			};
		}
	}

	// Find fallback model based on configuration
	function findFallbackModel(currentModel: any, config: any, ctx: ExtensionContext) {
		// Get the model registry from the context
		const modelRegistry = ctx.modelRegistry;
		if (!modelRegistry) {
			console.error("Fallback Models: No model registry available");
			return null;
		}

		const allModels = modelRegistry.getAll();

		// Create the full model identifier
		const currentModelKey = `${currentModel.provider}:${currentModel.id}`;

		// Try to find a model from the configured fallback list
		if (config.fallbackModels[currentModelKey]) {
			const preferredFallbacks = config.fallbackModels[currentModelKey];
			for (const modelKey of preferredFallbacks) {
				// Parse the model key (provider:model)
				const [provider, modelId] = modelKey.split(':');
				if (provider && modelId) {
					const model = modelRegistry.find(provider, modelId);
					if (model && !(model.provider === currentModel.provider && model.id === currentModel.id)) {
						return model;
					}
				}
			}
		}

		// No fallback found in configuration, return null
		return null;
	}

	// Start monitoring response time
	function startMonitoring(ctx: ExtensionContext) {
		// Clear existing timer
		if (timerId) {
			clearTimeout(timerId);
		}

		// Reset switch state for new requests
		hasSwitched = false;

		// Load configuration
		const config = loadConfig(ctx);

		// Start timeout timer
		timerId = setTimeout(async () => {
			// Check if still processing and hasn't already switched
			if (!ctx.isIdle() && !hasSwitched) {
				const currentModel = ctx.model;

				if (currentModel) {
					// Find a fallback model
					const fallbackModel = findFallbackModel(currentModel, config, ctx);

					if (fallbackModel) {
						try {
							// Cancel the current request
							ctx.abort();
							
							// Switch to fallback model
							const success = await pi.setModel(fallbackModel);
							if (success) {
								hasSwitched = true;
								if (ctx.hasUI) {
									ctx.ui.notify(
										`Cancelled slow request, retrying with: ${fallbackModel.provider}:${fallbackModel.id}`,
										"warning"
									);
								}
							}
						} catch (error) {
							console.error("Fallback Models error:", error);
						}
					}
				}
			}
		}, config.timeoutMs);
	}

	// Stop monitoring
	function stopMonitoring() {
		// Clear timer
		if (timerId) {
			clearTimeout(timerId);
			timerId = null;
		}
	}

	// Event handlers
	pi.on("agent_start", async (_event, ctx) => {
		startMonitoring(ctx);
	});

	pi.on("agent_end", async (_event, ctx) => {
		stopMonitoring();
	});

	pi.on("session_shutdown", async (_event, ctx) => {
		stopMonitoring();
	});

	pi.on("session_start", async (_event, ctx) => {
		// No status indicator
	});
}
