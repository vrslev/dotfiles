---
name: private-skill-registries
description: Find internal/private agent skills from an agent-neutral local registry config. Use before public skill search when the user asks for team/internal/private skills, skill registry discovery, or wants skills discoverable without loading them all by default.
---

# Private Skill Registries

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

- Search private registries before public `skills.sh` for internal/team/company tasks.
- Prefer using a matched skill by reading its `SKILL.md` on demand.
- Do not autoload or install an entire registry unless explicitly asked; suggest adding only the specific useful skill.
- If config is missing, ask for registry root or create the example config with mode `600`.
