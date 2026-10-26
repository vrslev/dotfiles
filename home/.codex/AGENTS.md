Reply in English unless asked otherwise. Prefer prose to bullet lists unless bullets materially improve clarity. For manually written external comments, match the thread language and start with `Агент:` in Russian or `Agent:` otherwise, followed by a blank line.

When drafting or rewriting prose in my voice, use the `writing-style` skill. Refine it only from my own corrections and clearly human-authored prose; exclude agent-generated or assisted text, even if I approved or posted it.

For GitLab merge-request titles and descriptions, use the `writing-style` skill.

Do not disclose internal information, including names, repository paths, hostnames, issue IDs, and URLs, to public or external systems outside its intended audience. Check code, tracked configuration, examples, tests, documentation, commits, and messages before publishing; keep necessary internal values in untracked local configuration.

Perform local work autonomously, including Git operations and dependency changes; commit and push when they are natural completion steps. For non-Git external systems such as messaging, email, and issue trackers, prepare drafts but publish only when explicitly requested or when the user-selected workflow includes publishing. In planning or preparation conversations, answers about scope, timing, or intended next steps are not publication approval. When publication or an external change is not yet authorized, show the final draft and proposed destinations/actions, then ask for explicit approval. Preserve user-edited external content.

The user manages their environment in `~/code/gh/vrslev/dotfiles`; prefer mise over global installations. Autonomously update `AGENTS.md` when the user states a durable behavior preference; keep one-off instructions local.

Reuse an existing Python environment when its interpreter, locked dependencies, editable-install paths, and concurrent use are compatible. Do not create an environment for every probe or copy environments into snapshots. Keep separate environments when dependencies or editable installs require it, and never mutate an environment another active task uses. Use the package manager's shared cache when creating environments. Remove temporary environments and regenerable build or benchmark artifacts when their task is finished, preserving source, patches, and evidence needed to reproduce the result.

Organize Codex projects by product or community, including their related service, package, and tooling repositories. Create standalone projects only for repositories outside those groups. Preserve per-repository Git histories and existing thread/worktree state when reorganizing projects.

Remove dependencies that become unused in the same change that removes their last consumer. Check application code, tests, tooling, entrypoints, plugins, and configuration before removal; keep dependencies with remaining supported consumers. Update the lockfile with the owning refactor rather than deferring its dependency cleanup to a separate task.

Treat applicable user, repository, and skill rules as requirements, including code style; severity is separate from compliance. Fix verified violations within the requested scope and report unrelated findings without expanding the task. Explain instruction conflicts that affect the work.

When asked to assess `Autonomous E2E`, use the user's definition: "without complaints in review". Check relevant Codex chats as well as merge-request reviews for corrective feedback. Assess completion readiness separately; manual setup or approval alone does not establish a review complaint.
