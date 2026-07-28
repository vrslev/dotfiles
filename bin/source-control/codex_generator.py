# pyright: strict

from __future__ import annotations

import subprocess
import tempfile
from pathlib import Path
from typing import Final

DISABLED_FEATURES: Final = (
    "browser_use",
    "browser_use_external",
    "browser_use_full_cdp_access",
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
    "skill_search",
    "tool_suggest",
)


class CodexGenerationError(RuntimeError):
    pass


def summarize_error_output(output: str) -> str:
    lines = output.strip().splitlines()
    return "\n".join(lines[-20:])[-4000:]


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
        ]
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
        if not output_path.exists():
            raise CodexGenerationError("codex did not write a final response")

        output = output_path.read_text().strip()
        if not output:
            raise CodexGenerationError("codex returned an empty final response")
        return output
