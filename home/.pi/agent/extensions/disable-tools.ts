export default function (pi) {
  const disabled = new Set(["revdiff_review", "code_search"]);

  function apply() {
    const keep = pi.getActiveTools().filter((n: string) => !disabled.has(n));
    pi.setActiveTools(keep);
  }

  pi.on("session_start", apply);
  pi.on("before_agent_start", apply);
}
