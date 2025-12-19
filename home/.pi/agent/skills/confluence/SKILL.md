---
name: confluence
description: Search and read Atlassian Confluence content.
version: 0.1.0
---

# Confluence

Search and read Atlassian Confluence content.

## Search

```bash
# Search for pages containing a query
confluence search "project documentation"

# Find a page by title, for example, extracted from url: https://confluence/pages/viewpage.action?title=Home+Adapter+Service
confluence find "Project Plan"
```

## Read

```bash
# Read a Confluence page in text format by id
confluence read 12345

# Get information about a specific page by id
confluence info 12345
```

## Learn more using help

```bash
confluence --help
confluence search --help
```

## When to Use

- Searching for documentation or API references
- Looking up facts or current information
- Fetching content from specific URLs by titlte
