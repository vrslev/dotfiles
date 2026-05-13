import { getAgentDir, type ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { spawnSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { join } from "node:path";

const GUARD_ENV = "PI_ANTHROPIC_REFRESH_RUNNING";

export default function piAnthropicRefresh(_pi: ExtensionAPI) {
  if (process.env[GUARD_ENV] === "1") return;

  const proxy = process.env.CLAUDE_PROXY;
  if (!proxy) return;

  const authPath = join(getAgentDir(), "auth.json");
  let expiresMs = 0;
  try {
    const parsed = JSON.parse(readFileSync(authPath, "utf-8")) as {
      anthropic?: { expires?: number };
    };
    expiresMs = Number(parsed?.anthropic?.expires ?? 0);
  } catch {}

  if (expiresMs > Date.now()) return;

  process.stderr.write("anthropic-refresh: creds expired → refreshing via $CLAUDE_PROXY\n");
  const result = spawnSync(process.execPath, [process.argv[1], "-p", "hi"], {
    env: { ...process.env, HTTPS_PROXY: proxy, [GUARD_ENV]: "1" },
    stdio: ["ignore", "pipe", "pipe"],
    encoding: "utf-8",
  });
  if (result.status !== 0) {
    process.stderr.write(
      `anthropic-refresh: refresh failed (status=${result.status})\n`,
    );
    if (result.stderr) process.stderr.write(result.stderr);
  }
}
