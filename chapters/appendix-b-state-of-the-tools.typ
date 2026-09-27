This appendix is deliberately perishable.

Everything in the main chapters is written to survive the next model release. This appendix is the opposite: it's a snapshot of the specific tools, models, standards, and price points as they stood when I finished the second edition. Some of it will be wrong within months. When it is, trust the principles in the chapters and check the vendors' current documentation — not this page.

// v2-verify: re-check every entry in this appendix against current vendor docs before each revision.

== Coding Agents

The market has settled into three shapes, and most vendors now offer all three.

*Terminal and IDE agents.* An agent that runs on your machine, in your repository, with your permission settings. Claude Code, OpenAI's Codex CLI, Gemini CLI, Cursor, GitHub Copilot's agent mode, and open-source agents such as Aider, Cline, opencode, and Goose. This is where most of the interactive work in this book happens.

*Cloud and background agents.* You hand over a task — often by assigning an issue — and the agent works in a hosted sandbox and comes back with a pull request. GitHub's Copilot coding agent, OpenAI Codex cloud tasks, Claude Code on the web, Cursor's background agents, and Google's Jules all work this way. This is the "overnight agent" from the Agents in the Pipeline chapter, turned into a product.

*Agent SDKs.* The building blocks for your own agents: the Claude Agent SDK (formerly the Claude Code SDK), the OpenAI Agents SDK, and a long tail of open-source frameworks. See the Building Your Own Agents chapter.

== Standards and Conventions

- *`AGENTS.md`* is the de facto cross-tool format for agent instruction files. Claude Code reads `CLAUDE.md`; a common pattern is to keep one file as the source of truth and have the other point at it.
- *Model Context Protocol (MCP)* is the standard way to connect agents to tools and data. Local servers talk over stdio; remote servers use Streamable HTTP with OAuth-based authorisation. Many vendors host official remote servers for their products. An official MCP Registry exists for discovery.
- In December 2025, MCP and `AGENTS.md` were placed under the Linux Foundation's Agentic AI Foundation, which moved both from vendor projects toward shared infrastructure.
- *Agent Skills* — folders containing a `SKILL.md` file plus optional scripts and reference material — were published as an open format and are supported by a growing number of tools. Only a skill's name and description sit in context until the skill is needed.
- *Hooks* (deterministic scripts that run before or after tool calls, or when the agent stops) and *plugins* (bundles of skills, commands, hooks, and MCP servers) are standard in the major agent tools, though the formats differ.

== Models

*Frontier commercial models.* Anthropic's Claude, OpenAI's GPT, and Google's Gemini families remain the strongest choice for long-horizon, multi-file agentic work. Context windows range from roughly 200,000 tokens to around a million on some models. Bigger windows haven't removed the need to curate context — see the Context chapter on context rot.

*Open-weight models.* Open-weight models improved dramatically for agentic coding through 2025 and 2026. At the time of writing, notable families include Qwen3-Coder, Kimi K2, GLM, OpenAI's open-weight gpt-oss models, DeepSeek, and Mistral's Devstral. Native context windows of 128K–256K tokens are common, although the usable context on a laptop is limited by memory long before it hits the model's limit.

*Running locally.* Ollama, LM Studio, llama.cpp, MLX (on Apple Silicon), and vLLM (on GPU servers) are the common runtimes. Smaller mixture-of-experts models — for example Qwen3-Coder-30B-A3B or gpt-oss-20b — run acceptably on a well-specified laptop. Many agent CLIs can point at any OpenAI-compatible endpoint, so a local model can drive a real agent loop. Claude Code is built for Anthropic's models; for local models, use an agent that supports local endpoints.

== Pricing

Pricing moved in two directions at once.

*Individuals mostly pay flat-rate subscriptions.* The major vendors offer entry plans around \$20 per month and heavy-use plans in the \$100–\$200 range, with usage limits instead of per-token bills. For a single engineer doing interactive work, this is usually the cheapest way to use frontier models.

*Per-token API pricing still matters* for CI jobs, background automation, products you build, and team accounts. Frontier per-token prices fell sharply over 2025, but agentic workloads consume so many tokens that the cost-control advice in the models and pipeline chapters still applies. Prompt caching remains the single easiest saving.

// v2-verify: subscription tiers and API prices before publishing a new revision.

== Security Incidents Worth Knowing

These are the public incidents referenced in the Agent Attack Surface chapter. Read the original write-ups — they're short, concrete, and more persuasive than any warning I can write.

- *GitHub MCP issue injection* (Invariant Labs, 2025): a malicious public issue led an agent with a broad token to leak private repository data.
- *Supabase MCP support-ticket injection* (2025): a support message led a privileged agent to expose sensitive data.
- *MCP tool poisoning* (Invariant Labs, 2025): hidden instructions in tool descriptions.
- *Amazon Q Developer extension* (July 2025): a destructive prompt shipped in a released version of a coding-assistant extension.
- *"s1ngularity" Nx supply-chain attack* (August 2025): malicious packages used locally installed AI coding CLIs to search developers' machines for secrets.
- *Slopsquatting*: attackers registering package names that models commonly hallucinate.

== Evidence on Productivity

- *METR (July 2025):* in a randomised controlled trial, experienced open-source developers working in their own mature repositories were about 19% slower with early-2025 AI tools — while believing they had been about 20% faster. The tools have improved since; the gap between feeling fast and being fast is still worth measuring.
- *DORA (2025):* AI use was nearly universal among respondents, and the report's central finding was that AI acts as an amplifier — it magnifies a team's existing strengths and weaknesses.

== How to Keep This Appendix Honest

If you're reading this more than six months after September 2026, assume at least a third of it is stale. The questions to ask of any new tool haven't changed: What can it see? What can it touch? How does it get feedback? How do I review its work? What happens when it reads something hostile? Answer those, and the product names stop mattering.
