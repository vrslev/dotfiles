#!/usr/bin/env python3
"""Search private Agent Skills registries."""

import argparse
import json
import os
import re
import sys
from pathlib import Path

ENV = "AGENT_SKILL_REGISTRIES_CONFIG"
DEFAULT = "agent-skills/private-registries.json"
SKIP = {".git", ".hg", ".svn", "node_modules", "__pycache__", ".venv", "venv"}
FM = re.compile(r"\s*---\s*\r?\n(.*?)\r?\n---\s*\r?\n", re.S)
KEY = re.compile(r"^([A-Za-z0-9_-]+):(?:\s*(.*))?$")
WORD = re.compile(r"[^0-9a-zа-яё]+")


def eprint(*xs):
    print(*xs, file=sys.stderr)


def xp(path, base=None):
    p = Path(os.path.expandvars(os.path.expanduser(str(path))))
    return (base / p if base and not p.is_absolute() else p).resolve()


def cfg_path(value):
    if value or os.environ.get(ENV):
        return xp(value or os.environ[ENV])
    base = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    return (base / DEFAULT).resolve()


def as_list(value):
    if value is None:
        return []
    if isinstance(value, str):
        return [value]
    if isinstance(value, dict):
        if value.get("enabled", True) is False:
            return []
        return as_list(value.get("path") or value.get("dir") or value.get("root"))
    if isinstance(value, list):
        out = []
        for item in value:
            out.extend(as_list(item))
        return out
    return [str(value)]


def pick(obj, *keys):
    return next((obj[k] for k in keys if k in obj), None)


def load_registries(path):
    if path.exists():
        try:
            cfg = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            raise SystemExit(f"Invalid JSON in {path}: {exc}") from exc
    else:
        cfg = {"registries": []}

    items = cfg if isinstance(cfg, list) else cfg.get("registries", [])
    if not isinstance(items, list):
        raise SystemExit(f"Invalid config {path}: 'registries' must be a list")

    regs = []
    for i, item in enumerate(items, 1):
        if not isinstance(item, dict) or item.get("enabled", True) is False:
            continue
        root_raw = item.get("root") or item.get("path")
        if not root_raw:
            eprint(f"warning: skip registry #{i}: missing root/path")
            continue
        root = xp(root_raw)
        dirs = as_list(pick(item, "skills", "skillDirs", "skillsDirs", "skillDir", "skillsDir"))
        regs.append(
            {
                "name": str(item.get("name") or root.name or f"registry-{i}"),
                "root": root,
                "dirs": dirs or (["skills"] if (root / "skills").exists() else ["."]),
                "description": str(item.get("description") or ""),
                "source": str(item.get("source") or item.get("repo") or item.get("url") or ""),
                "priority": int(item.get("priority") or 0),
                "tags": as_list(item.get("tags")),
            }
        )
    return regs


def skill_files(base):
    if (base / "SKILL.md").is_file():
        yield base / "SKILL.md"
        return
    if not base.exists():
        return
    for root, dirs, files in os.walk(base):
        dirs[:] = [d for d in dirs if d not in SKIP and not d.startswith(".")]
        if "SKILL.md" in files:
            yield Path(root) / "SKILL.md"
            dirs[:] = []


def frontmatter(text):
    match = FM.match(text)
    if not match:
        return {}
    lines, out, i = match.group(1).splitlines(), {}, 0
    while i < len(lines):
        m = KEY.match(lines[i])
        if not m:
            i += 1
            continue
        key, val = m.group(1), (m.group(2) or "").strip()
        if val in {">", "|", ">-", "|-", ">+", "|+"}:
            block = []
            i += 1
            while i < len(lines) and not KEY.match(lines[i]):
                if lines[i].strip():
                    block.append(lines[i].strip())
                i += 1
            out[key] = " ".join(block)
        else:
            out[key] = val.strip("'\"")
            i += 1
    return out


def load_skills(regs, verbose=False):
    out, seen = [], set()
    for reg in regs:
        if not reg["root"].exists():
            if verbose:
                eprint(f"warning: registry root does not exist: {reg['root']}")
            continue
        for rel in reg["dirs"]:
            base = xp(rel, reg["root"])
            if not base.exists():
                if verbose:
                    eprint(f"warning: skill dir does not exist: {base}")
                continue
            for path in skill_files(base):
                path = path.resolve()
                if path in seen:
                    continue
                seen.add(path)
                fm = frontmatter(path.read_text(encoding="utf-8", errors="replace"))
                desc = (fm.get("description") or "").strip()
                if desc:
                    out.append({"name": fm.get("name") or path.parent.name, "description": desc, "path": path, "registry": reg})
    return out


def tokens(text):
    return [w for w in WORD.split(text.lower()) if w]


def score(skill, query):
    reg = skill["registry"]
    name, desc, path = skill["name"].lower(), skill["description"].lower(), str(skill["path"]).lower()
    reg_text = f"{reg['name']} {reg['description']} {' '.join(reg['tags'])}".lower()
    haystack = f"{name} {desc} {path} {reg_text}"
    q = query.lower().strip()
    total = reg["priority"]
    if not q:
        return total
    total += 120 if q == name else 0
    total += 70 if q in name else 0
    total += 35 if q in desc else 0
    total += 15 if q in path else 0
    for word in tokens(q):
        total += 35 if word in name else 0
        total += 12 if word in desc else 0
        total += 8 if word in reg_text else 0
        total += 5 if word in path else 0
        total -= 3 if word not in haystack else 0
    return total


def rank(skills, query, include_weak=False):
    for skill in skills:
        skill["score"] = score(skill, query)
    if query and not include_weak:
        skills = [s for s in skills if s["score"] > s["registry"]["priority"]]
    return sorted(skills, key=lambda s: (-s["score"], -s["registry"]["priority"], s["registry"]["name"], s["name"]))


def public(skill):
    reg = skill["registry"]
    return {
        "name": skill["name"],
        "description": skill["description"],
        "path": str(skill["path"]),
        "registry": reg["name"],
        "registryRoot": str(reg["root"]),
        "source": reg["source"],
        "score": skill["score"],
    }


def print_text(config, query, skills, top):
    print(f"Config: {config}")
    if query:
        print(f"Query: {query}")
    print(("Matches" if query else "Skills") + f": {len(skills)}")
    if not skills:
        print("No private skills found.")
        return
    for i, skill in enumerate(skills[:top], 1):
        reg = skill["registry"]
        src = f" · source: {reg['source']}" if reg["source"] else ""
        print(f"\n{i}. {skill['name']}  [registry: {reg['name']} · score: {skill['score']}{src}]")
        print(f"   {skill['description']}")
        print(f"   {skill['path']}")


def init_example(path, force=False):
    if path.exists() and not force:
        raise SystemExit(f"Refusing to overwrite {path}; use --force")
    path.parent.mkdir(parents=True, exist_ok=True)
    data = {"version": 1, "registries": [{"name": "team-skills", "root": "~/path/to/private-skills-repo", "skills": ["skills"], "source": "ssh://git@example.org/group/private-skills.git", "priority": 100, "enabled": True}]}
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    path.chmod(0o600)
    print(path)


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("query", nargs="*")
    ap.add_argument("--config")
    ap.add_argument("--top", type=int, default=10)
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--include-weak", action="store_true")
    ap.add_argument("--verbose", action="store_true")
    ap.add_argument("--init-example", action="store_true")
    ap.add_argument("--force", action="store_true")
    args = ap.parse_args(argv)

    config = cfg_path(args.config)
    if args.init_example:
        init_example(config, args.force)
        return 0

    query = " ".join(args.query).strip()
    search_query = "" if args.list else query
    skills = rank(load_skills(load_registries(config), args.verbose), search_query, args.include_weak)
    if args.json:
        print(json.dumps({"config": str(config), "query": search_query, "results": [public(s) for s in skills[: args.top]], "totalResults": len(skills)}, ensure_ascii=False, indent=2))
    else:
        if not config.exists():
            eprint(f"warning: config does not exist: {config}")
        print_text(config, search_query, skills, args.top)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
