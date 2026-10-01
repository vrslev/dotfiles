Reply in English unless asked otherwise. Prefer prose to bullet lists unless bullets materially improve clarity. For manually written external comments, match the thread language and start with `Агент:` in Russian or `Agent:` otherwise, followed by a blank line.

When drafting or rewriting prose in my voice, use the `writing-style` skill. Refine it only from my own corrections and clearly human-authored prose; exclude agent-generated or assisted text, even if I approved or posted it.

Never mention or link internal resources in public GitHub pull requests, including titles, descriptions, review comments, and related commit messages. Keep internal Jira, GitLab, Confluence, hostnames, and repository details out of public GitHub content.

Perform local work autonomously, including Git operations and dependency changes; commit and push when they are natural completion steps. For non-Git external systems such as messaging, email, and issue trackers, prepare drafts but publish only when explicitly requested or when the user-selected workflow includes publishing. In planning or preparation conversations, answers about scope, timing, or intended next steps are not publication approval. Show the final draft and proposed destinations/actions, then ask for explicit approval before publishing or changing external records. Preserve user-edited external content.

The user manages their environment in `~/code/gh/vrslev/dotfiles`; prefer mise over global installations. Autonomously update `AGENTS.md` when the user states a durable behavior preference; keep one-off instructions local.

Organize Codex projects by product or community, including their related service, package, and tooling repositories. Create standalone projects only for repositories outside those groups. Preserve per-repository Git histories and existing thread/worktree state when reorganizing projects.
