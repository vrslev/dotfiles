/**
 * Simple Think Tool - A tool that accepts a thought and outputs nothing
 */

import { Type } from "@sinclair/typebox";
import type { CustomToolFactory } from "@mariozechner/pi-coding-agent";

const factory: CustomToolFactory = (pi) => ({
  name: "think",
  label: "Think",
  description: "Use the tool to think about something. It will not obtain new information or change the database, but just append the thought to the log. Use it when complex reasoning or some cache memory is needed.",
  parameters: Type.Object({
    thought: Type.String({ description: "A thought to think about." }),
  }),

  async execute(toolCallId, params) {
    // Accept the thought parameter but don't output anything
    return {
      content: [{ type: "text", text: params.thought }], // Empty output
      details: { thought: params.thought },
    };
  },
});

export default factory;
