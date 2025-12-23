/**
 * Simple Think Tool - A tool that accepts a thought and outputs nothing
 */

import { Type } from "@sinclair/typebox";
import { Text } from "@mariozechner/pi-tui";
import type { CustomToolFactory } from "@mariozechner/pi-coding-agent";

const factory: CustomToolFactory = (pi) => ({
  name: "think",
  label: "Think",
  description: "Use the tool to think about something. It will not obtain new information or change the database, but just append the thought to the log. Use it when complex reasoning or some cache memory is needed.",
  parameters: Type.Object({
    thought: Type.String({ description: "A thought to think about." }),
  }),

  async execute(toolCallId, params, signal, onUpdate) {
    return {
      content: [{ type: "text", text: "OK" }], // Minimal feedback for LLM
      details: { thought: params.thought },
    };
  },

  renderResult(result) {
    return new Text(result.details.thought, 0, 0);
  },
});

export default factory;
