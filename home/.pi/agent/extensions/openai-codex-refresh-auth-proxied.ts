import { spawnSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { getAgentDir, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

const GUARD_ENV = "PI_OPENAI_CODEX_REFRESH_RUNNING";

export default function piOpenAICodexRefresh(_pi: ExtensionAPI) {
  if (process.env[GUARD_ENV] === "1") return;

  const proxy = process.env.OPENAI_CODEX_PROXY ?? process.env.CLAUDE_PROXY;
  if (!proxy) return;

  const authPath = join(getAgentDir(), "auth.json");
  let expiresMs = 0;
  try {
    const parsed = JSON.parse(readFileSync(authPath, "utf-8")) as {
      ["openai-codex"]?: { expires?: number };
    };
    expiresMs = Number(parsed?.["openai-codex"]?.expires ?? 0);
  } catch {}

  if (expiresMs > Date.now()) return;

  process.stderr.write("openai-codex-refresh: creds expired → refreshing via proxy\n");
  const result = spawnSync(process.execPath, [
    process.argv[1],
    "--provider",
    "openai-codex",
    "--model",
    "gpt-5.5",
    "-p",
    "hi",
  ], {
    env: { ...process.env, HTTPS_PROXY: proxy, [GUARD_ENV]: "1" },
    stdio: ["ignore", "pipe", "pipe"],
    encoding: "utf-8",
  });
  if (result.status !== 0) {
    process.stderr.write(
      `openai-codex-refresh: refresh failed (status=${result.status})\n`,
    );
    if (result.stderr) process.stderr.write(result.stderr);
  }
}
