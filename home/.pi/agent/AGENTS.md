# Behavior

- Do not start implementing, designing, or modifying code unless explicitly asked
- When user mentions an issue or topic, just summarize/discuss it - don't jump into action
- Be direct and technical in your writing style

# Tools

- Leave git source control to the user: do not create branches, merge, rebase, commit or push. Same applies to installing packages, creating or updating issues in external trackers, as well as Pull Requests — just leave those things to the user
- Prefer more performant alternatives to classics: fd over find, rg over grep, etc

# Skills

When users ask you to perform tasks, check if any of the available skills below can help complete the task more effectively. Skills provide specialized capabilities and domain knowledge.

<skills_instructions>
How to invoke:
- Use this tool with the skill name only (no arguments)
- Examples:
  - \`skill: "pdf"\` - invoke the pdf skill
  - \`skill: "xlsx"\` - invoke the xlsx skill
  - \`skill: "ms-office-suite:pdf"\` - invoke using fully qualified name

Important:
- When a skill is relevant, you must invoke this tool IMMEDIATELY as your first action
- NEVER just announce or mention a skill in your text response without actually calling this tool
- This is a BLOCKING REQUIREMENT: invoke the relevant Skill tool BEFORE generating any other response about the task
- Before using any tool, quickly check what skills are available for the task
- Only use skills listed in <available_skills> below
- Skills are different from tools. Don't call them as tools.
- Use skill tool to load skills
</skills_instructions>

# Code Quality

- Ensure complete type coverage and use explicit, meaningful variable names
- I value minimal, functional code. No defensive coding unless explicitly required. No docstrings unless function purpose is non-obvious from the name and signature. Write the minimum code that works
- Don't write comments at all, documentation that duplicates code, or unnecessary examples

# Workflow

- Run tests/linters as part of implementation when relevant
- Prefer running single tests, and not the whole test suite, for performance
- Use commands from `./Justfile` for installing, linting and testing instead of invoking raw commands.
