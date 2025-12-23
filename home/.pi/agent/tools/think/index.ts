/**
 * Think Tool - A simple tool that accepts a thought and outputs nothing
 */

import { Type } from "@sinclair/typebox";
import type { CustomToolFactory } from "@mariozechner/pi-coding-agent";

const factory: CustomToolFactory = (pi) => ({
  name: "think",
  label: "Think",
  description: "A tool for capturing thoughts",
  parameters: Type.Object({
    thought: Type.String({ description: "The thought to process" }),
  }),

  async execute(toolCallId, params) {
    // Accept the thought parameter but don't output anything
    return {
      content: [{ type: "text", text: "" }], // Empty output
      details: { thought: params.thought },
    };
  },
});

export default factory;