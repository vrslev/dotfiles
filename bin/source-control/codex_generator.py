# pyright: strict

from __future__ import annotations

import json
import re
import subprocess
import tempfile
from pathlib import Path
from typing import Final

DISABLED_FEATURES: Final = (
    "apps",
    "browser_use",
    "browser_use_external",
    "browser_use_full_cdp_access",
    "code_mode",
    "computer_use",
    "goals",
    "hooks",
    "image_generation",
    "in_app_browser",
    "memories",
    "multi_agent",
    "multi_agent_v2",
    "plugins",
    "remote_plugin",
    "remote_compaction_v2",
    "shell_snapshot",
    "shell_tool",
    "skill_search",
    "tool_suggest",
    "unified_exec",
)
ALLOWED_ITEM_TYPES: Final = {"agent_message", "error", "reasoning"}


class CodexGenerationError(RuntimeError):
    pass


def summarize_error_output(output: str) -> str:
    lines = output.strip().splitlines()
    return "\n".join(lines[-20:])[-4000:]


def config_key_segment(value: str) -> str:
    if re.fullmatch(r"[A-Za-z0-9_-]+", value) is None:
        raise CodexGenerationError(f"unsupported Codex config key: {value!r}")
    return value


def build_mcp_disable_arguments() -> list[str]:
    completed_process = subprocess.run(
        ["codex", "mcp", "list", "--json"],
        capture_output=True,
        text=True,
        timeout=5,
        check=False,
    )
    if completed_process.returncode != 0:
        raise CodexGenerationError("failed to list configured MCP servers")
    try:
        configured_servers = json.loads(completed_process.stdout)
        server_names = [server["name"] for server in configured_servers]
    except (json.JSONDecodeError, KeyError, TypeError) as error:
        raise CodexGenerationError("failed to parse configured MCP servers") from error

    arguments: list[str] = []
    for server_name in server_names:
        arguments.extend(["-c", f"mcp_servers.{config_key_segment(server_name)}.enabled=false"])
    return arguments


def validate_single_turn(event_stream: str) -> None:
    turn_started_count = 0
    turn_completed_count = 0
    unexpected_item_types: set[str] = set()
    try:
        events = [json.loads(line) for line in event_stream.splitlines() if line.strip()]
    except json.JSONDecodeError as error:
        raise CodexGenerationError("codex returned invalid JSONL events") from error

    for event in events:
        event_type = event.get("type")
        if event_type == "turn.started":
            turn_started_count += 1
        elif event_type == "turn.completed":
            turn_completed_count += 1
        elif event_type in {"item.started", "item.completed"}:
            item_type = event.get("item", {}).get("type")
            if item_type not in ALLOWED_ITEM_TYPES:
                unexpected_item_types.add(str(item_type))

    if turn_started_count != 1 or turn_completed_count != 1:
        raise CodexGenerationError(
            f"expected exactly one completed turn, got started={turn_started_count}, completed={turn_completed_count}"
        )
    if unexpected_item_types:
        raise CodexGenerationError(f"codex used tools: {', '.join(sorted(unexpected_item_types))}")


def generate_with_codex(
    prompt: str,
    context: str,
    *,
    model: str,
    reasoning_effort: str,
    timeout_seconds: float,
) -> str:
    with tempfile.TemporaryDirectory(prefix="codex-generator-") as temporary_directory:
        output_path = Path(temporary_directory) / "last-message.txt"
        command = [
            "codex",
            "exec",
            "--ephemeral",
            "--json",
            "--sandbox",
            "read-only",
            "--skip-git-repo-check",
            "--ignore-rules",
            "--cd",
            temporary_directory,
            "--color",
            "never",
            "--output-last-message",
            str(output_path),
            "--model",
            model,
            "-c",
            f'model_reasoning_effort="{reasoning_effort}"',
            "-c",
            "notify=[]",
            "-c",
            'web_search="disabled"',
            "-c",
            "tools.view_image=false",
            "-c",
            "include_skills_usage_instructions=false",
            "-c",
            "include_apps_instructions=false",
            "-c",
            "include_permissions_instructions=false",
            "-c",
            "include_collaboration_mode_instructions=false",
            "-c",
            "include_environment_context=false",
            "-c",
            "project_doc_max_bytes=0",
        ]
        command.extend(build_mcp_disable_arguments())
        for feature in DISABLED_FEATURES:
            command.extend(["--disable", feature])
        command.append(prompt)

        completed_process = subprocess.run(
            command,
            input=context,
            capture_output=True,
            text=True,
            timeout=timeout_seconds,
            check=False,
        )
        if completed_process.returncode != 0:
            error_output = summarize_error_output(completed_process.stderr or completed_process.stdout)
            raise CodexGenerationError(error_output or f"codex exited with {completed_process.returncode}")
        validate_single_turn(completed_process.stdout)
        if not output_path.exists():
            raise CodexGenerationError("codex did not write a final response")

        output = output_path.read_text().strip()
        if not output:
            raise CodexGenerationError("codex returned an empty final response")
        return output
