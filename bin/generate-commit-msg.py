# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "ollama",
#     "pydantic",
# ]
# ///
import subprocess
import sys
from contextlib import suppress

import ollama
import pydantic

MODEL = "phi3"
PROMPT = """
Write concise, informative short commit messages:

- One line that contains the summary of the changes
- Imperative style
- Avoid referring to external sources
- If there are no changes, or the input is blank - then return a blank string

Think carefully before you write your commit message.

**User will send you raw diff. You should respond with commit message only. Don't provide extra assistance — just commit message would be enough!**

What you write will be passed directly to git commit -m "[message]"

Respond in format:

{"commit_message": "[message]"}
"""


class LLMResponse(pydantic.BaseModel):
    commit_message: str


with suppress(KeyboardInterrupt):
    staged_diff = subprocess.check_output(("git", "diff", "--staged")).decode()
    all_responses = []

    for _ in range(3):
        ollama_response = ollama.chat(
            model=MODEL,
            messages=[
                {"role": "system", "content": PROMPT},
                {"role": "user", "content": staged_diff},
            ],
            format="json",
        )
        message_content = ollama_response["message"]["content"]
        all_responses.append(message_content)

        try:
            commit_message = LLMResponse.model_validate_json(
                message_content
            ).commit_message
        except pydantic.ValidationError:
            pass
        else:
            print(commit_message)
            raise SystemExit(0)

    print("Failed to parse responses:\n", file=sys.stderr)
    for response in all_responses:
        print(f"{response!r}\n", file=sys.stderr)
    raise SystemExit(1)
