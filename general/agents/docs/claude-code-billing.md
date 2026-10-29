# Claude Code billing

- Never use tools that scrape or impersonate Claude Code's OAuth tokens; they violate the terms. Tools that wrap the local `claude` CLI (interactive or Agent SDK) are allowed (Anthropic's public confirmation to T3 Code).
- Signed in with the plan, interactive Claude Code, `claude -p`, the Agent SDK and GitHub Actions bill from the plan's limits. The announced June 15 split onto a separate Agent SDK credit was paused before taking effect.
- A third-party harness doing its own subscription login (such as Pi's `/login`) is sanctioned since 2026-04-04 but bills per token from claude.ai extra usage, not plan limits. Anthropic's 2026-10-07 wording ("third-party apps with your subscription limits") may mean otherwise; unconfirmed, so check the usage page after a session.
- Max and Team plans include monthly API credits ($100 Max 5x, $200 Max 20x, up to $500 pooled on Team), claimed by linking one Console org in claude.ai billing settings. They cover the Claude API, Managed Agents, and the Agent SDK or `claude -p` run with an API key from that org; not interactive Claude Code, extra usage, or Bedrock/Vertex/Foundry. No rollover; when they run out, requests stop rather than billing the plan.
- For Pi or OpenCode, an API key from the linked org is the clean path onto the credits. Harnesses that send the `claude-code-20250219` beta header on API-key requests may be refused as Claude Code traffic (one unconfirmed report, OmniRoute #15942).

Verified 2026-10-14 against Anthropic's support articles and the Claude Platform docs. Anthropic has changed this repeatedly, so re-check before relying on it.
