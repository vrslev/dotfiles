---
name: brainstorm-funnel
description: Structured brainstorming when the user asks to explore options, compare approaches, or solve an ambiguous product, prompt, architecture, workflow, or design problem. Generates diverse options, clusters ideas, scores tradeoffs, and converges without generic ideation bloat. Avoid for straightforward implementation/debugging tasks.
---

# Brainstorm Funnel

Explore broadly, then converge quickly. Do not stop at the first plausible idea.

## Workflow

1. State the goal, constraints, and decision criteria. Ask only if missing information would change the direction.
2. Generate options across several useful lenses:
   - boring and robust
   - cheapest reversible experiment
   - high-upside weird idea
   - user-experience improvement
   - failure-prevention or safety improvement
   - simplification or removal
   - automation or tooling
3. Cluster related ideas and remove duplicates.
4. Turn shortlisted ideas into concrete cases: named scope/actors, current pain, proposed actions, observable outcome or metric, and the first reversible step.
5. Check altitude against the request: classify each option as task, project, program, or strategy and reject options below the required level.
6. Score by impact, effort, risk, reversibility, and confidence; recommend only when the user wants convergence.

## Output

- **Goal / constraints**
- **Idea clusters** with concrete representative cases
- **Top options** table: case, outcome, impact, effort, risk, reversibility, confidence
- **Recommendation** with rationale
- **Next experiment**

## Rules

- Use the output structure when helpful; otherwise adapt to the user’s requested format and keep the response proportional to the task.
- Default to 3–5 idea clusters and 2–4 top options unless the user asks for exhaustive brainstorming.
- Never leave a shortlisted option as an abstract label. When context exists, name the actual product flow, services, teams, owner boundary, actions, and evidence; mark missing facts explicitly.
- Prefer testable outcomes and before/after measures over activities or artifacts.
- For career, leadership, or staff-level planning, reject work that one engineer or team can routinely deliver in one quarter. Require a multi-quarter outcome, several independent stakeholders or teams, durable change to strategy or operating model, decision authority, and work scaled through others.
- When the user asks for several alternatives, require each shortlisted option to pass independently. Do not turn alternatives into supporting workstreams for a preferred option or anchor the comparison around one favorite.
- Exclude initiatives already owned or underway unless the user could receive a distinct, explicitly transferred scope.
- Include at least one removal/simplification option when relevant.
- Mark assumptions and uncertainty rather than padding with caveats.
