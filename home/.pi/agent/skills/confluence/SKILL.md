---
name: confluence
description: Read Atlassian Confluence content via the official confluence CLI; trigger this skill to retrieve page content using deterministic shell commands.
version: 0.1.0
---

# Confluence CLI Skill

This skill provides integration with the Confluence CLI tool for reading Atlassian Confluence content. Note: Only the 'read' command is available due to system restrictions.

## Usage

Use this skill to read Confluence page content via the official confluence CLI. The only available command is:

- Reading page content by ID or URL

## Prerequisites

- Confluence CLI installed and configured
- Proper authentication credentials set up

## Examples

```bash
# Read a Confluence page in text format (default)
confluence read 12345

# Read a Confluence page in Markdown format
confluence read --format markdown 12345

# Read a Confluence page by URL
confluence read https://your-domain.atlassian.net/wiki/spaces/KEY/pages/12345
```

## Configuration

The skill expects the `confluence` CLI to be available in PATH and properly authenticated. Configuration is typically done via environment variables or a configuration file as specified by the Confluence CLI documentation.

## Notes

- This skill is designed to work with the official Atlassian Confluence CLI
- Only the 'read' command is available due to system restrictions
- All operations are performed via the CLI tool, so ensure it's installed and configured before use
- This skill is read-only - no create, update, or delete operations are permitted

For more information about the Confluence CLI, see: https://developer.atlassian.com/server/confluence/confluence-cli/
