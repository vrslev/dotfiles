---
name: private-skill-registries
description: Cheap first-stop for discovering private/internal/team/company agent skills from a local registry config before inventing a workflow or searching public skills. Finds hidden or unloaded SKILL.md files without adding every private repo to context or dotfiles.
---

# Private Skill Registries

Run one quick private-registry search whenever a task might already have a reusable team skill. The cost is tiny, and the upside is high: better internal instructions, existing helper scripts, and less chance of re-inventing a workflow.

Discover private skills without loading every private `SKILL.md` into context and without committing concrete local paths to agent settings.

## Config

Agent-neutral, untracked config:

```text
$AGENT_SKILL_REGISTRIES_CONFIG
# default: $XDG_CONFIG_HOME/agent-skills/private-registries.json
# usually: ~/.config/agent-skills/private-registries.json
```

Minimal shape:

```json
{
  "version": 1,
  "registries": [
    {
      "name": "team-skills",
      "root": "~/path/to/private-skills-repo",
      "skills": ["skills"],
      "source": "ssh://git@example.org/group/private-skills.git",
      "priority": 100,
      "enabled": true
    }
  ]
}
```

Notes: `root` may be `path`; `skills` may be `skillDir(s)` / `skillsDir(s)`. If omitted, scan `root/skills` if it exists, otherwise `root`. Keep concrete private paths only in this config, not in git-backed dotfiles or agent settings.

## Use

Resolve the helper relative to this skill directory and run:

```bash
python3 <this-skill-dir>/scripts/search_private_skills.py --top 8 "<query>"
```

Then read the best 1-3 matching `SKILL.md` files before recommending or using one.

Common commands:

```bash
python3 <this-skill-dir>/scripts/search_private_skills.py --list
python3 <this-skill-dir>/scripts/search_private_skills.py --json "jira"
python3 <this-skill-dir>/scripts/search_private_skills.py --init-example
```

## Policy

- Make this the first cheap check for internal, private, team, or company workflows/tools/docs.
- Search before creating a reusable workflow, writing a new skill, or using public skill search.
- Prefer using a matched skill by reading its `SKILL.md` on demand.
- If there are no good matches, continue normally and mention that no private skill matched.
- Do not autoload or install an entire registry unless explicitly asked; suggest adding only the specific useful skill.
- If config is missing, ask for registry root or create the example config with mode `600`.
