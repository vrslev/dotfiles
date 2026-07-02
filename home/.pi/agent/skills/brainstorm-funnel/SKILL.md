---
name: brainstorm-funnel
description: Structured brainstorming when the user asks to explore options, compare approaches, or solve an ambiguous product, prompt, architecture, workflow, or design problem. Generates diverse options, clusters ideas, scores tradeoffs, and converges without generic ideation bloat. Avoid for straightforward implementation/debugging tasks.
---

# Brainstorm Funnel

Use divergent thinking first, then converge quickly. Avoid stopping at the first plausible idea.

## Workflow

1. State the goal, constraints, and decision criteria. Ask only if missing information would change the direction.
2. Generate options across several relevant lenses, not necessarily all:
   - boring and robust
   - cheapest reversible experiment
   - high-upside weird idea
   - user-experience improvement
   - failure-prevention or safety improvement
   - simplification or removal
   - automation or tooling
3. Cluster similar ideas into themes and remove duplicates.
4. Score promising options by impact, effort, risk, reversibility, and confidence.
5. Recommend a short list, often 2–3 options; include “do nothing / defer” when it is a realistic choice.
6. Suggest the next smallest experiment or implementation step.

## Output

- **Goal / constraints**
- **Idea clusters** with representative ideas
- **Top options** table: impact, effort, risk, reversibility, confidence
- **Recommendation** with rationale
- **Next experiment**

## Rules

- Use the output structure when helpful; otherwise adapt to the user’s requested format and keep the response proportional to the task.
- Default to 3–5 idea clusters and 2–4 top options unless the user asks for exhaustive brainstorming.
- Prefer specific, testable ideas over slogans.
- Include at least one removal/simplification option when relevant.
- Mark assumptions and uncertainty rather than padding with caveats.
