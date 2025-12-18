---
name: confluence
description: Read and search Atlassian Confluence content.
version: 0.1.0
---

# Confluence CLI Skill

This skill provides integration with the Confluence CLI tool for reading Atlassian Confluence content.

## Usage

Use this skill to interact with Atlassian Confluence via the official confluence CLI. The following commands are available:

- Reading page content by ID (read)
- Searching for pages (search)
- Getting page information (info)
- Finding pages by title (find)
- Displaying help (--help)

## Examples

```bash
# Read a Confluence page in text format (default)
confluence read 12345

# Search for pages containing a query
confluence search "project documentation"

# Get information about a specific page
confluence info 12345

# Find a page by title
confluence find "Project Plan"

# Display help information
confluence --help
```

## Configuration

The skill expects the `confluence` CLI to be available in PATH and properly authenticated. Configuration is typically done via environment variables or a configuration file as specified by the Confluence CLI documentation.

## Notes

- This skill is designed to work with the official Atlassian Confluence CLI
- All operations are performed via the CLI tool, so ensure it's installed and configured before use
- This skill is read-only - no create, update, or delete operations are permitted

For more information about the Confluence CLI, see: https://developer.atlassian.com/server/confluence/confluence-cli/
