---
name: private-skill-registries
description: Discover internal/private agent skills from an agent-neutral local registry config. Use when the user asks to find, choose, read, or install a team/internal/private skill; mentions skill registry; says not to load all skills by default; or asks whether a skill exists in local/private repos before falling back to public skills.sh.
---

# Private Skill Registries

Use this skill to discover private/internal skills without loading every private skill into the agent's system prompt and without storing concrete private paths in git-backed or agent-specific settings.

This is intentionally **agent-neutral**: the registry config is shared across Pi, Claude Code, Codex, Cursor, OpenCode, etc. Only this finder skill needs to be installed in a given agent.

## Config

Registry paths live in an untracked, agent-neutral config file:

```text
$AGENT_SKILL_REGISTRIES_CONFIG
# or, by default:
$XDG_CONFIG_HOME/agent-skills/private-registries.json
# usually:
~/.config/agent-skills/private-registries.json
```

Supported JSON / JSONC shape:

```jsonc
{
  "version": 1,
  "registries": [
    {
      "name": "team-skills",
      "description": "Short human description",
      "root": "~/path/to/private-skills-repo",
      "skills": ["skills"],
      "source": "ssh://git@example.org/group/private-skills.git", // optional install/update source
      "priority": 100,
      "tags": ["team", "internal"],
      "enabled": true
    }
  ]
}
```

Field aliases:

- `root` or `path` — registry root.
- `skills`, `skillsDir`, `skillDir`, `skillsDirs`, or `skillDirs` — directories under `root` to scan. If omitted, `skills/` is used when it exists; otherwise the root itself is scanned.
- `skills` may contain strings or objects like `{ "path": "skills/team", "enabled": true }`.
- `source`, `repo`, or `url` — optional remote/source string to show install/update commands.
- `priority` — optional ordering hint; higher means preferred.
- `tags` — optional search hints.

Never put concrete private registry roots into git-tracked `settings.json`, package manifests, AGENTS.md/CLAUDE.md, or this skill file. Put them only in the private config above.

## Workflow

1. When the user asks for an internal/private/team skill, search private registries first.

   After reading this skill file, resolve the helper path relative to this skill directory (`scripts/search_private_skills.py`) and run:

   ```bash
   python3 <this-skill-dir>/scripts/search_private_skills.py --top 8 "<query>"
   ```

2. Read the 1-3 most promising `SKILL.md` files before recommending or using a skill. Do not rely on name alone.

3. If a match is relevant:
   - use the skill instructions directly by reading its `SKILL.md`;
   - if the user asks to install/autoload it, recommend adding only that specific skill path with the current agent's normal skill-install mechanism.

4. If no private match is found, then fall back to public discovery (`find-skills`, `skills.sh`, or `npx skills find`).

5. If the config is missing or empty, ask the user for the private registry root and create/update only the agent-neutral config with restrictive permissions (`chmod 600`). Do not write concrete paths into git-backed dotfiles.

## Commands

Create example config:

```bash
python3 <this-skill-dir>/scripts/search_private_skills.py --init-example
```

Search:

```bash
python3 <this-skill-dir>/scripts/search_private_skills.py "chatbot data import"
```

List all configured private skills:

```bash
python3 <this-skill-dir>/scripts/search_private_skills.py --list
```

JSON output for scripting:

```bash
python3 <this-skill-dir>/scripts/search_private_skills.py --json "jira"
```

Use another config:

```bash
AGENT_SKILL_REGISTRIES_CONFIG=/private/config.json \
  python3 <this-skill-dir>/scripts/search_private_skills.py "ab test"
```

## Recommendation format

Keep recommendations short:

```text
Found private skill: <name>
Why: <1 sentence>
Source: <registry name>
Read: <absolute path to SKILL.md>
Next: I can use it now, or add just this skill to this agent's autoload/install config.
```

## Guardrails

- Prefer private registries for internal/company/team tasks.
- Do not globally include an entire private registry unless the user explicitly asks.
- Do not persist discovered paths into git-backed dotfiles.
- Do not recommend public skills for internal-only data/workflows until private registries were checked.
- If several skills match, choose the narrowest one for the user's task.
