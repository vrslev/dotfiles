---
name: double-check
description: Independent review of code, diffs, plans, or specs for bugs, regressions, scope drift, and missed validation. Use for explicit review/sanity-check requests; skip for casual command/status checks.
metadata:
  license: Inspired by pi-review-loop (https://github.com/nicobailon/pi-review-loop)
---

# Double-Check

Act as a second-pass reviewer.

1. Identify scope: user request, changed files/diff, linked ticket/spec/plan if provided.
2. Read touched files plus direct callers/tests; expand only when needed.
3. Check correctness, edge cases, scope drift, project instructions, and validation.
4. Prefer reporting issues. Edit only when the user asked to fix, or the issue is clearly in changes you just made.
5. Run the smallest relevant check when practical; state checks not run.

For large or high-risk reviews, use a fresh subagent/session when available.

Output:
- If issues: list them by severity with fix status.
- If none: state what was reviewed and checks run, ending with `No issues found.`
