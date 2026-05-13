# AGENTS.md

## Project Overview
- Dotfiles repository for macOS development environment
- Managed with Fish shell, mise, Git, VS Code, Ghostty, Zed
- Includes AI agent configurations in `home/.pi/agent/`
- Repository structure designed for easy symlink management

## Notable Directories
- [`bin/`](bin/): Custom utility scripts and tools
- [`home/.config/fish/`](home/.config/fish/): Fish shell configuration and aliases
- [`home/.config/git/`](home/.config/git/): Git configuration, aliases, and settings
- [`home/.config/mise/`](home/.config/mise/): Language version management configuration
- [`home/Library/Application Support/Code/`](home/Library/Application Support/Code/): VS Code settings and extensions
- [`home/.config/ghostty/`](home/.config/ghostty/): Ghostty terminal configuration
- [`home/.pi/agent/`](home/.pi/agent/): AI agent configuration and behavior rules

## Key Configuration Areas
- **Shell**: Fish with custom configurations, functions, and utilities in `home/.config/fish/`
- **Languages**: Managed with mise (Python, Node.js, Go, Rust, etc.) via `home/.config/mise/config.toml`
- **Version Control**: Git with extensive aliases and configurations in `home/.config/git/`
- **Editors**: 
  - VS Code settings, keybindings, and extensions in `home/Library/Application Support/Code/User/`
  - Zed editor configuration in `home/Library/Application Support/Zed/`
- **Terminal**: Ghostty with custom configuration in `home/.config/ghostty/config`
- **Custom Tools**: All scripts in `bin/` directory are available in PATH for easy execution

## Development Environment
- **Operating System**: macOS with custom defaults applied
- **Shell**: Fish with starship prompt and custom utilities
- **Language Management**: mise for Python, Node.js, Go, Rust version management
- **Tools**: eza (modern ls), tmux, starship, ty, opencode, and others
- **Code Quality**: Biome, Ruff, MyPy, Hadolint integrations
- **Task Runner**: Go Task (taskfile) for automation

## Installed Tools (Brewfile)
- **CLI Tools**: fish, git, mise, eza, tmux, tree, wget, parallel, etc.
- **Development**: go-task, kubernetes-cli, postgresql@14, glab, etc.
- **Applications**: Visual Studio Code, Zed, Ghostty, Rectangle, Orbstack, etc.
- **VS Code Extensions**: Python, Biome, GitLens, Ruff, and others

## Agent Integration Points
- Behavior configuration: `home/.pi/agent/AGENTS.md`
- Custom commands: `home/.pi/agent/commands/`
- Skills integrations: `home/.pi/agent/skills/`
- Custom tools: `home/.pi/agent/tools/`
- System prompt reference: `home/.pi/agent/reference-pi-system-prompt.md`