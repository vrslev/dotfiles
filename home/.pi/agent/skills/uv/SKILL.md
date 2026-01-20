---
name: uv
description: Comprehensive guide for using uv as a modern Python package manager and project tool. Use when managing Python projects, dependencies, virtual environments, or when needing fast pip-compatible operations with enhanced project management capabilities.
metadata:
  short-description: Modern Python package manager and project tool
---

# uv - Ultra Fast Python Package Manager

uv is a modern, ultra-fast Python package manager written in Rust. It serves as both a pip-compatible package installer and a comprehensive project management tool.

## Key Concepts

uv operates in two distinct modes:

1. **Project Mode**: Modern Python project management with pyproject.toml integration
2. **pip Compatibility Mode**: Drop-in replacement for pip with enhanced speed

## Project Management (Recommended)

Modern Python development with uv centers around projects defined in `pyproject.toml`:

### Initialize a New Project

```bash
# Create a new application project
uv init my-app

# Create a new library project
uv init my-library --lib

# Create a minimal pyproject.toml only
uv init my-project --bare
```

### Managing Dependencies

```bash
# Add production dependencies
uv add requests django

# Add development dependencies
uv add --dev pytest black ruff

# Add optional dependencies for extras
uv add --optional test pytest

# Add with version constraints
uv add django@">=4.2,<5.0"

# Add from Git
uv add git+https://github.com/user/repo.git

# Remove dependencies
uv remove django
```

### Sync Environment

```bash
# Install all dependencies and sync environment
uv sync

# Include optional dependencies
uv sync --extra test

# Include all optional dependencies
uv sync --all-extras

# Development-only dependencies
uv sync --only-dev

# Exact sync (removes extraneous packages)
uv sync --inexact
```

## pip Compatibility Mode

For direct package management without project integration:

### Virtual Environments

```bash
# Create virtual environment
uv venv

# Create with specific Python version
uv venv --python 3.11

# Activate (Unix)
source .venv/bin/activate

# Activate (Windows)
.venv\Scripts\Activate.ps1
```

### Package Installation

```bash
# Install packages
uv pip install requests django

# Install with constraints
uv pip install -c constraints.txt requests

# Install from requirements file
uv pip install -r requirements.txt

# Install in editable mode
uv pip install -e .

# Upgrade packages
uv pip install --upgrade django
```

### Environment Inspection

```bash
# List installed packages
uv pip list

# Show package information
uv pip show django

# Export frozen requirements
uv pip freeze > requirements.txt

# Check environment
uv pip check
```

## Best Practices

### 1. Use Project Mode for Applications

Always prefer project mode for applications with `pyproject.toml` rather than loose requirements files.

### 2. Dependency Management Strategy

- Define direct dependencies explicitly in `pyproject.toml`
- Let uv handle transitive dependency resolution
- Use lock files (`uv.lock`) for reproducible builds
- Separate development and production dependencies

### 3. Python Version Management

```bash
# Specify Python version requirement in pyproject.toml
uv init my-project --python 3.11

# Use specific Python version
uv sync --python 3.11
```

### 4. Workspace Management

For monorepos with multiple packages:

```bash
# Add package to workspace
uv add ../shared-lib --workspace
```

## Common Workflows

### Starting a New Project

```bash
# 1. Initialize project
uv init my-awesome-project

# 2. Navigate to project
cd my-awesome-project

# 3. Add dependencies
uv add requests
uv add --dev pytest black ruff

# 4. Sync environment
uv sync

# 5. Activate environment
source .venv/bin/activate
```

### Working with Existing Projects

```bash
# For projects with pyproject.toml
uv sync

# For projects with requirements.txt
uv venv
source .venv/bin/activate
uv pip install -r requirements.txt
```

### Running Scripts and Commands

```bash
# Run Python script with isolated environment
uv run script.py

# Run command with project dependencies
uv run python -c "import requests; print(requests.__version__)"

# Run development tools
uv run pytest
uv run black .
```

## Performance Tips

1. **Use uv's built-in caching**: Enabled by default, significantly faster than pip
2. **Prefer wheels over source distributions**: uv excels at wheel installation
3. **Use parallel resolution**: Built-in to uv, no configuration needed
4. **Leverage lock files**: `uv.lock` ensures consistent, fast installs

## Troubleshooting

### Resolution Issues

```bash
# Refresh cached data
uv sync --refresh

# Refresh specific package
uv sync --refresh-package django

# Force reinstall
uv sync --reinstall
```

### Network Issues

```bash
# Work offline with cached data
uv sync --offline

# Use custom index
uv sync --index https://custom-pypi.example.com/simple
```

### Platform-Specific Installs

```bash
# Target different platforms
uv sync --python-platform aarch64-apple-darwin
```

## When to Use Each Mode

### Project Mode (Preferred)
- Application development
- Library development
- Team projects requiring reproducibility
- Projects with complex dependency requirements

### pip Mode
- Quick package installations
- Legacy projects with requirements.txt
- System-wide package management
- Integration with existing pip-based workflows



Remember: uv is not just a faster pip—it's a complete Python project management solution. Prefer project workflows over pip compatibility mode for better dependency management and reproducibility.