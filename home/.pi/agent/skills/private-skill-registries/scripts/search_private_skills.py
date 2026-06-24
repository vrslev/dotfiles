#!/usr/bin/env python3
"""Search agent-agnostic private skill registries."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterable

CONFIG_ENV = "AGENT_SKILL_REGISTRIES_CONFIG"
DEFAULT_CONFIG_RELATIVE = "agent-skills/private-registries.json"
SKIP_DIRS = {
    ".git",
    ".hg",
    ".svn",
    "node_modules",
    "__pycache__",
    ".venv",
    "venv",
    ".tox",
    ".mypy_cache",
    ".pytest_cache",
}


@dataclass
class Registry:
    name: str
    root: Path
    skill_dirs: list[str]
    description: str = ""
    source: str = ""
    priority: int = 0
    tags: list[str] = field(default_factory=list)


@dataclass
class Skill:
    name: str
    description: str
    file_path: Path
    registry: Registry
    score: int = 0


def eprint(*args: object) -> None:
    print(*args, file=sys.stderr)


def default_config_path() -> Path:
    xdg_config = os.environ.get("XDG_CONFIG_HOME")
    base = Path(xdg_config).expanduser() if xdg_config else Path.home() / ".config"
    return (base / DEFAULT_CONFIG_RELATIVE).resolve()


def resolve_config_path(raw: str | None) -> Path:
    value = raw or os.environ.get(CONFIG_ENV)
    if value:
        return expand_path(value)
    return default_config_path()


def strip_json_comments(text: str) -> str:
    """Remove // and /* */ comments while preserving string contents."""
    out: list[str] = []
    i = 0
    in_string = False
    escape = False

    while i < len(text):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ""

        if in_string:
            out.append(ch)
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == '"':
                in_string = False
            i += 1
            continue

        if ch == '"':
            in_string = True
            out.append(ch)
            i += 1
            continue

        if ch == "/" and nxt == "/":
            i += 2
            while i < len(text) and text[i] not in "\r\n":
                i += 1
            if i < len(text):
                out.append(text[i])
                i += 1
            continue

        if ch == "/" and nxt == "*":
            i += 2
            while i + 1 < len(text) and not (text[i] == "*" and text[i + 1] == "/"):
                if text[i] in "\r\n":
                    out.append(text[i])
                i += 1
            i += 2 if i + 1 < len(text) else 0
            continue

        out.append(ch)
        i += 1

    return "".join(out)


def expand_path(raw: str, base: Path | None = None) -> Path:
    expanded = os.path.expandvars(os.path.expanduser(raw))
    path = Path(expanded)
    if not path.is_absolute() and base is not None:
        path = base / path
    return path.resolve()


def as_string_list(value: Any) -> list[str]:
    if value is None:
        return []
    if isinstance(value, str):
        return [value]
    if isinstance(value, list):
        result: list[str] = []
        for item in value:
            if isinstance(item, str) and item.strip():
                result.append(item)
            elif isinstance(item, dict) and item.get("enabled", True) is not False:
                path = item.get("path") or item.get("dir") or item.get("root")
                if path:
                    result.append(str(path))
        return result
    if isinstance(value, dict):
        if value.get("enabled", True) is False:
            return []
        path = value.get("path") or value.get("dir") or value.get("root")
        return [str(path)] if path else []
    return [str(value)]


def load_config(path: Path) -> dict[str, Any] | list[Any]:
    if not path.exists():
        return {"registries": []}
    try:
        return json.loads(strip_json_comments(path.read_text(encoding="utf-8")))
    except json.JSONDecodeError as exc:
        raise SystemExit(f"Invalid JSON in {path}: {exc}") from exc


def load_registries(config_path: Path) -> list[Registry]:
    config = load_config(config_path)
    raw_registries = config if isinstance(config, list) else config.get("registries", [])
    if not isinstance(raw_registries, list):
        raise SystemExit(f"Invalid config {config_path}: 'registries' must be a list")

    registries: list[Registry] = []
    for idx, item in enumerate(raw_registries, start=1):
        if not isinstance(item, dict):
            eprint(f"warning: skip registry #{idx}: expected object")
            continue
        if item.get("enabled", True) is False:
            continue

        raw_root = item.get("root") or item.get("path")
        if not raw_root:
            eprint(f"warning: skip registry #{idx}: missing root/path")
            continue

        root = expand_path(str(raw_root))
        raw_skill_dirs = first_present(
            item,
            "skills",
            "skillDirs",
            "skillsDirs",
            "skillDir",
            "skillsDir",
        )
        skill_dirs = as_string_list(raw_skill_dirs)
        if not skill_dirs:
            skill_dirs = ["skills"] if (root / "skills").exists() else ["."]

        registries.append(
            Registry(
                name=str(item.get("name") or root.name or f"registry-{idx}"),
                root=root,
                skill_dirs=skill_dirs,
                description=str(item.get("description") or ""),
                source=str(item.get("source") or item.get("repo") or item.get("url") or ""),
                priority=parse_int(item.get("priority"), default=0),
                tags=as_string_list(item.get("tags")),
            )
        )
    return registries


def first_present(mapping: dict[str, Any], *keys: str) -> Any:
    for key in keys:
        if key in mapping:
            return mapping[key]
    return None


def parse_int(value: Any, default: int = 0) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def iter_skill_files(base: Path) -> Iterable[Path]:
    if (base / "SKILL.md").is_file():
        yield base / "SKILL.md"
        return

    if not base.exists():
        return

    for root, dirs, files in os.walk(base):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS and not d.startswith(".")]
        if "SKILL.md" in files:
            yield Path(root) / "SKILL.md"
            # Skill roots are terminal; do not recurse into nested support dirs.
            dirs[:] = []


def strip_quotes(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {'"', "'"}:
        return value[1:-1]
    return value


def parse_frontmatter(content: str) -> dict[str, str]:
    match = re.match(r"\s*---\s*\r?\n(.*?)\r?\n---\s*\r?\n", content, flags=re.DOTALL)
    if not match:
        return {}

    lines = match.group(1).splitlines()
    values: dict[str, str] = {}
    i = 0
    key_re = re.compile(r"^([A-Za-z0-9_-]+):(?:\s*(.*))?$")

    while i < len(lines):
        line = lines[i]
        m = key_re.match(line)
        if not m:
            i += 1
            continue

        key, raw_value = m.group(1), (m.group(2) or "").rstrip()
        if raw_value in {">", "|", ">-", "|-", ">+", "|+"}:
            block: list[str] = []
            i += 1
            while i < len(lines) and not key_re.match(lines[i]):
                piece = lines[i].strip()
                if piece:
                    block.append(piece)
                i += 1
            values[key] = " ".join(block).strip()
            continue

        values[key] = strip_quotes(raw_value)
        i += 1

    return values


def load_skill(file_path: Path, registry: Registry) -> Skill | None:
    try:
        content = file_path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        content = file_path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        eprint(f"warning: cannot read {file_path}: {exc}")
        return None

    fm = parse_frontmatter(content)
    name = fm.get("name") or file_path.parent.name
    description = fm.get("description") or ""
    if not description.strip():
        # Most agents ignore skills without a description; keep results aligned.
        return None
    return Skill(name=name, description=description.strip(), file_path=file_path, registry=registry)


def discover_skills(registries: Iterable[Registry], verbose: bool = False) -> list[Skill]:
    skills: list[Skill] = []
    seen: set[Path] = set()

    for registry in registries:
        if not registry.root.exists():
            if verbose:
                eprint(f"warning: registry root does not exist: {registry.root}")
            continue

        for skill_dir in registry.skill_dirs:
            base = expand_path(skill_dir, registry.root)
            if not base.exists():
                if verbose:
                    eprint(f"warning: skill dir does not exist: {base}")
                continue

            for file_path in iter_skill_files(base):
                real = file_path.resolve()
                if real in seen:
                    continue
                seen.add(real)
                skill = load_skill(file_path, registry)
                if skill is not None:
                    skills.append(skill)

    return skills


def tokenize(text: str) -> list[str]:
    return [t for t in re.split(r"[^a-z0-9а-яё]+", text.lower()) if t]


def score_skill(skill: Skill, query: str) -> int:
    if not query.strip():
        return 1

    query_norm = query.lower().strip()
    query_tokens = tokenize(query)
    name = skill.name.lower()
    desc = skill.description.lower()
    path = str(skill.file_path).lower()
    registry_text = f"{skill.registry.name} {skill.registry.description} {' '.join(skill.registry.tags)}".lower()
    haystack = f"{name} {desc} {path} {registry_text}"

    score = skill.registry.priority
    if query_norm == name:
        score += 120
    if query_norm in name:
        score += 70
    if query_norm in desc:
        score += 35
    if query_norm in path:
        score += 15

    for token in query_tokens:
        if token == name:
            score += 80
        elif token in name:
            score += 35
        if token in desc:
            score += 12
        if token in registry_text:
            score += 8
        if token in path:
            score += 5
        if token not in haystack:
            score -= 3

    return score


def filter_and_rank(skills: list[Skill], query: str, include_zero: bool = False) -> list[Skill]:
    ranked: list[Skill] = []
    for skill in skills:
        skill.score = score_skill(skill, query)
        if include_zero or not query.strip() or skill.score > skill.registry.priority:
            ranked.append(skill)
    ranked.sort(key=lambda s: (-s.score, -s.registry.priority, s.registry.name, s.name, str(s.file_path)))
    return ranked


def skill_to_dict(skill: Skill) -> dict[str, Any]:
    return {
        "name": skill.name,
        "description": skill.description,
        "path": str(skill.file_path),
        "registry": skill.registry.name,
        "registryRoot": str(skill.registry.root),
        "source": skill.registry.source,
        "priority": skill.registry.priority,
        "score": skill.score,
    }


def print_text(skills: list[Skill], config_path: Path, query: str, top: int) -> None:
    shown = skills[:top]
    print(f"Config: {config_path}")
    if query.strip():
        print(f"Query: {query}")
    print(f"Matches: {len(skills)}" if query.strip() else f"Skills: {len(skills)}")
    if not shown:
        print("No private skills found.")
        return

    for idx, skill in enumerate(shown, start=1):
        source = f" · source: {skill.registry.source}" if skill.registry.source else ""
        print(f"\n{idx}. {skill.name}  [registry: {skill.registry.name} · score: {skill.score}{source}]")
        print(f"   {skill.description}")
        print(f"   {skill.file_path}")


def create_example_config(path: Path, force: bool = False) -> None:
    if path.exists() and not force:
        raise SystemExit(f"Refusing to overwrite existing config: {path} (use --force)")
    path.parent.mkdir(parents=True, exist_ok=True)
    data = {
        "version": 1,
        "registries": [
            {
                "name": "example-team-skills",
                "description": "Private/team skill repository",
                "root": "~/path/to/private-skills-repo",
                "skills": ["skills"],
                "source": "ssh://git@example.org/group/private-skills.git",
                "priority": 100,
                "tags": ["team", "internal"],
                "enabled": True,
            }
        ],
    }
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    try:
        path.chmod(0o600)
    except OSError:
        pass
    print(path)


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("query", nargs="*", help="Search query")
    parser.add_argument("--config", help=f"Config path. Defaults to ${CONFIG_ENV} or XDG config.")
    parser.add_argument("--top", type=int, default=10, help="Number of results to print")
    parser.add_argument("--list", action="store_true", help="List all configured private skills")
    parser.add_argument("--json", action="store_true", help="Print JSON")
    parser.add_argument("--include-zero", action="store_true", help="Include zero-score query results")
    parser.add_argument("--verbose", action="store_true", help="Print warnings for missing paths")
    parser.add_argument("--init-example", action="store_true", help="Create an example config at the resolved config path")
    parser.add_argument("--force", action="store_true", help="Overwrite when used with --init-example")
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    config_path = resolve_config_path(args.config)

    if args.init_example:
        create_example_config(config_path, force=args.force)
        return 0

    query = " ".join(args.query).strip()
    registries = load_registries(config_path)
    skills = discover_skills(registries, verbose=args.verbose)

    if args.list or not query:
        ranked = filter_and_rank(skills, "", include_zero=True)
    else:
        ranked = filter_and_rank(skills, query, include_zero=args.include_zero)

    if args.json:
        payload = {
            "config": str(config_path),
            "query": query,
            "registries": [
                {
                    "name": r.name,
                    "root": str(r.root),
                    "skills": r.skill_dirs,
                    "description": r.description,
                    "source": r.source,
                    "priority": r.priority,
                    "tags": r.tags,
                }
                for r in registries
            ],
            "results": [skill_to_dict(skill) for skill in ranked[: args.top]],
            "totalResults": len(ranked),
        }
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    else:
        if not config_path.exists():
            eprint(
                f"warning: config does not exist: {config_path}\n"
                f"create one with: {Path(__file__).name} --init-example"
            )
        print_text(ranked, config_path, query, args.top)

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
