---
name: double-check
description: Thorough review of plan/spec documents and code with fresh eyes. Use when asked to "review", "double-check", "look over", "sanity check", or "find bugs in" a plan or codebase.
metadata:
  license: Inspired by pi-review-loop (https://github.com/nicobailon/pi-review-loop)
---

# Double-Check

Review plan/spec (if one exists) and all relevant code with fresh eyes, looking for bugs, errors, issues, and unnecessary complexity.

## Process

1. **Find context**: Locate any plan/spec files and all relevant source code
2. **Read everything**: Read all relevant files completely before making any judgment
3. **Think deeply**: Trace through edge cases, question every assumption, ultrathink
4. **Fix issues**: Plan issues go in the plan, code issues go in the code

## Plan Review

If a plan/spec file exists, review it against the codebase first. If the plan has issues, fix the plan document only — do NOT edit source code to fix plan issues.

## Code Review

Question everything. Does each line of code need to exist? Remove unused parameters, dead code, and unnecessary complexity — don't dress them up with underscore prefixes or comments. Address pre-existing issues too.

This codebase will outlive you. Every shortcut becomes someone else's burden. Every hack compounds into technical debt. The patterns you establish will be copied. The corners you cut will be cut again. Fight entropy. Leave the codebase better than you found it.

## Response Format

- **Issues found**: Fix them, list what was fixed, end with "Fixed [N] issue(s). Ready for another review."
- **No issues found**: Describe what was examined and verified, conclude with "No issues found."

Do not rush to a verdict. This is not an MVP — don't skip anything.
