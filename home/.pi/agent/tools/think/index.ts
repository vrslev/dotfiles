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
    onUpdate?.({
      content: [{ type: "text", text: params.thought }],
      details: { thought: params.thought },
    });
    return {
      content: [{ type: "text", text: "OK" }], // Minimal feedback for LLM
      details: { thought: params.thought },
    };
  },

  renderCall(args, theme) {
    let text = theme.fg("toolTitle", theme.bold("think "));
    if (args.thought) {
      text += theme.fg("dim", `${args.thought}`);
    }
    return new Text(text, 0, 0);
  },

  renderResult() {
    return new Text(undefined, 0, 0);
  },
});

export default factory;
