---
name: eval-designer
description: 'Design lightweight evaluations for prompts, skills, agents, and workflow changes: before/after test prompts, success criteria, negative cases, edge cases, regression risks, and manual or scripted eval plans.'
---

# Eval Designer

Create the smallest evaluation that can detect whether a prompt, skill, or workflow change helped.

## Workflow

1. Define the target behavior, scope, and users.
2. List likely failure modes and regressions.
3. Build a compact eval set, usually 6–10 cases:
   - positive cases where the behavior should happen
   - negative cases where it should not trigger
   - edge cases with ambiguity or conflicting goals
   - regression cases for behavior that must stay unchanged
4. Write expected behavior for each case before judging outputs.
5. Choose a simple scoring rubric: pass/fail or 0–2 is usually enough.
6. Propose a run plan: manual comparison, scripted harness, or session-log sampling.
7. Explain how to interpret results and what would justify reverting.

## Output

- **Target behavior**
- **Failure modes**
- **Eval cases** table: input/scenario, expected behavior, pass criteria
- **Scoring rubric**
- **Run plan**
- **Decision rule**: ship, iterate, or revert

## Rules

- Use the output structure when helpful; otherwise adapt to the user’s requested format and keep the response proportional to the task.
- Default to 6–10 eval cases. Add more only when the user asks for broad coverage or the change is high-risk.
- Keep evals small enough to run before the change gets forgotten.
- Include non-trigger cases for skill/prompt activation changes.
- Prefer manual or semi-manual evals unless automation is cheap, repeatable, and likely to be reused.
- Avoid overfitting to one transcript; prefer representative prompts.
- Do not build a large benchmark unless explicitly requested.
