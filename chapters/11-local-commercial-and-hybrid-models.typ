= Local, Commercial, and Hybrid Models

A friend of mine — senior engineer at a Series B startup — pinged me on a Friday afternoon. "I just got our first real API bill. Twenty-two hundred dollars. For _March_." He'd been running Claude Code across his team of eight engineers, each of them iterating on features, debugging, refactoring. Nobody had set token budgets. Nobody was watching the meter. The agents worked beautifully, and the invoice was eye-watering.

That same week, I talked to an engineer at a healthcare company in Munich. She was running Llama 70B on a local GPU server because their patient data pipeline couldn't touch external APIs. Not "shouldn't" — _couldn't_. Their compliance team had made that clear in writing. She was getting decent results for focused tasks, but every time she needed complex multi-file reasoning, the model fell apart and she found herself doing the work manually.

These two stories are the bookends of the same question: where does the model run? It sounds like an infrastructure decision. It's really a decision about trust, cost, capability, and — increasingly — how you architect your entire agentic workflow.

I told both stories in the first edition, and both would play out a little differently today. The bill would more likely be a stack of flat-rate subscriptions. The local model would be a lot more capable. But the question underneath hasn't moved an inch.

This chapter avoids model names and prices wherever it can, because they go stale in months. For the current snapshot — which models, which tools, what they cost — see Appendix B: The State of the Tools.

== Commercial Models: The Frontier

Commercial models — Claude, GPT, Gemini — are where the frontier lives. If you're doing serious agentic engineering, you've probably spent most of your time here. There are good reasons for that.

=== Context Windows, and Using Them Well

Context is everything for agents. An agent doesn't just read your prompt — it reads files, tool outputs, error messages, test results, and its own previous reasoning. A multi-step debugging session can run to hundreds of thousands of tokens.

Frontier models now offer windows from a couple of hundred thousand tokens up to around a million. That's a lot of room. But a big window isn't the same as good use of one. Research on "context rot" has shown that model performance degrades as input grows — well before the advertised limit. An agent at 80% of its window is not reasoning as well as the same agent at 20%. That's why the Context chapter spends so long on curation, compaction, and sub-agents: a bigger window buys you slack, not a licence to stop curating.

The difference between frontier and local here is less about what the model card says and more about what your hardware can hold. Many open models now ship with native windows of 128K tokens or more. But on a laptop, memory for the context competes with memory for the model itself. In practice, local RAM — not the spec sheet — sets how much context you can actually use.

=== Tool Use and Instruction Following

Agents live and die by tool use. Reading files, writing code, running commands, searching codebases — that's the core loop. Frontier models have been trained hard on it. They format arguments correctly, chain calls logically, recover when a call fails, read a file before editing it, run the tests after changing it.

They also listen. When you say "only modify files in `src/auth/`" or "don't change the public API," a frontier model generally stays inside the lines, even deep into a long session.

This is the area where open-weight models improved the most over 2025 and 2026. Models built specifically for agentic coding closed much of the gap on tool calling and instruction following. On a well-scoped task, a good open model now behaves like a real agent, not a chatbot pretending to be one.

Where the gap remains is on _long-horizon_ work: many steps, many files, a plan that has to survive dozens of tool calls. Smaller models are more likely to drift — forget the plan, revisit decisions, loop on a failing command, quietly ignore a constraint from forty turns ago. Each step is a little less reliable, and over a long task the errors compound. In a sandbox that's annoying. Without one, it's dangerous.

=== Choosing the Right Commercial Model

Not all commercial models are interchangeable, even at the frontier. Here's what I've found in practice:

*For complex multi-file refactoring and architectural work* — use the most capable model you can get. This is where reasoning quality matters most, and the difference between tiers is often the difference between a clean diff and a mess you redo by hand.

*For focused single-file tasks* — writing tests, implementing a well-defined function, fixing a clear bug — mid-tier models perform almost as well as top-tier ones, for much less. The task is scoped enough that the model doesn't need to juggle many concerns.

*For high-volume, low-complexity work* — boilerplate, formatting, commit messages — the cheapest model that follows instructions is the right choice. You'll run these hundreds of times.

The mistake I see most often is using a single model for everything. That's like driving a Formula 1 car to the grocery store. Match the model to the task.

== Local Models: The Full Picture

Running an open-weight model locally — through Ollama, LM Studio, llama.cpp, MLX, or vLLM — gives you something commercial APIs can't: complete data sovereignty and zero marginal cost per token.

Your code never leaves your machine. Proprietary source, internal documents, production logs, the API key you accidentally left in a config — none of it crosses a network boundary. And once the model is downloaded, every inference is free. Run it all night; nobody sends you a bill.

The story changed a lot between the first edition of this book and this one. Open-weight models — from Chinese labs, from Mistral, even an open-weight release from OpenAI — got dramatically better at agentic coding. And the tooling caught up: many agent CLIs now accept any OpenAI-compatible endpoint, so a local model can drive a real agent loop — reading files, running tests, iterating — not just autocomplete.

But let's be honest about the experience, because the marketing around local models often isn't.

=== The Hardware Reality

The hardware question is the first one everyone asks, and the answer is less glamorous than the "run AI locally!" posts suggest.

*A well-specced laptop (Apple Silicon with 32GB or more of unified memory, or equivalent).* The sweet spot for individual developers. Mixture-of-experts models help a lot here: they have many parameters but only activate a fraction of them per token, so a model that's large on disk can still run at a usable speed. Expect it to be noticeably slower than a commercial API, and expect to trade context length against model size — the more memory the model takes, the less is left for the conversation.

*A dedicated GPU box or server.* This is where local inference gets genuinely fast and where the larger open models become practical. But now you're maintaining hardware — drivers, memory management, and the occasional "why is my GPU fan screaming at 3am" incident. For a team, a shared inference server running vLLM is often a better investment than a dozen maxed-out laptops.

*Modest hardware (16GB of RAM, no discrete GPU).* You're limited to small models and short contexts. Fine for experimentation and simple completions; frustrating for real agentic work.

The honest summary: local models are practical if you have serious memory to throw at them. Below that threshold, you'll have a frustrating experience. Above it, you'll have a genuinely useful tool — just a different tool from a frontier API.

=== Where Local Models Shine

Local models aren't just "worse commercial models." There are workflows where they genuinely make more sense:

*High-frequency, low-stakes tasks.* Docstrings, commit messages, boilerplate, data formatting. These don't need a genius — they need a fast, free model you can fire-and-forget.

*Sensitive codebases.* If your code can't leave your network, local models are the only option, and "good enough" is infinitely better than "not available." More on this in the privacy section.

*Offline development.* On a plane, on a train, in a bunker — your local model works without WiFi. This sounds minor until you're on a twelve-hour flight trying to debug something.

*Experimentation and learning.* When you're building agent tooling, testing prompt strategies, or wiring up custom integrations, trial-and-error against a metered API feels wasteful. A local model lets you iterate freely.

=== Where Local Models Struggle

"It's less capable" is too vague to be useful. Here's where the gap actually shows up:

*Long-horizon, multi-file work.* Tracing a bug across four services and a schema, or carrying a refactor across a dozen files, is where local models most often lose the plot. They find the right file but misread how the pieces interact, or they lose track of the plan halfway through.

*Long sessions.* Local context is constrained by memory, and quality falls off as the context fills. The same session that stays coherent on a frontier model starts repeating itself locally.

*Nuanced judgement.* "This code is correct but the approach is wrong" requires deep understanding. Local models tend toward surface-level review — they'll catch obvious bugs but miss architectural problems.

*Speed.* Even when the answer is right, waiting for it on local hardware adds up over a hundred tool calls.

None of this makes local models useless. A good open coding model running locally handles a surprising range of well-scoped tasks. But scope them accordingly. Asking a local model to do exactly what a frontier model does is setting it up to fail.

== The Cost of Agentic Work

An agentic session consumes far more tokens than people expect — not because you're chatting, but because the agent is _working_.

Consider a moderately complex bug fix. The agent reads three or four files to understand the context. It reasons about the problem. It reads two more files, writes a fix, runs the tests. They fail. It reads the error, revises, runs them again. They pass. It reads the diff to double-check. Every one of those steps re-sends the growing conversation, so even a straightforward fix can run to tens of thousands of tokens. A complex refactor — twenty files read, eight changed, the test suite run four times, two regressions debugged — runs to hundreds of thousands.

How that turns into money depends on how you pay.

=== Subscriptions and Tokens

Between the first edition and this one, the way most individuals pay for agentic coding changed. The major vendors now sell flat-rate subscriptions with usage limits: an entry tier for regular use, and heavy-use tiers several times the price for people who run agents all day. You don't see a per-token bill. You see a rate limit when you've used your share.

For an individual developer, this is usually the right way to pay. Your cost is predictable, and a runaway session hits a usage cap rather than your credit card.

Per-token API pricing still matters — a lot — in three places:

- *CI and automation.* Agents in your pipeline, review bots, scheduled jobs. The Agents in the Pipeline chapter covers these; they run on API keys, and they can run a lot.
- *Products.* If you're building agents into something you ship, every user's session is your token bill.
- *Teams.* Some organisations prefer centrally managed API access over individual subscriptions, for visibility, compliance, or procurement reasons.

The good news: frontier token prices fell sharply over 2025, and the trend is still downward. The bad news: agents found ways to use more tokens just as fast. Whichever way you pay, the relative picture holds — a vague, exploratory, multi-hour session costs many times what a tightly scoped fix does. For current prices and plan tiers, see Appendix B.

=== Strategies for Managing Cost

The solution isn't to stop using agents. It's to be smart about it.

*Set limits.* Cap turns or tokens per task where your tool allows it — in headless mode, Claude Code's `--max-turns` flag does this. This isn't just cost control, it's a quality signal. If an agent burns ten times the usual effort on a task, something has gone wrong: it's stuck, looping, or misunderstanding the task. A limit makes it fail fast rather than spiral.

*Use model routing.* Don't send every task to the most expensive model. Cheap, fast models for exploration and code reading; the capable model for reasoning and planning. More on this below.

*Cache aggressively.* Much of an agent's context repeats between turns — the same system prompt, the same instruction files, the same recently-read files. If you're on an API, make sure prompt caching is on.

*Scope tasks tightly.* "Fix the timezone bug in `billing/invoice.py`, the test is in `tests/test_invoice.py`" is cheaper than "fix the billing bugs." The agent reads fewer files, makes fewer exploratory calls, and converges faster. On a subscription, the same discipline means you hit your usage limit later.

*Review your failures.* When a task fails or takes far too long, figure out why. Vague prompt? Missing context? Model not capable enough? Each failure is a tuning opportunity.

=== Managing Costs Across a Team

Individual cost control is one thing. Managing spend across a team of eight or twelve engineers, each running agents all day — plus whatever's running in CI — is a different problem entirely. It's the difference between watching your own diet and running a restaurant kitchen.

*Budgets.* Whether you're paying for seats or tokens, give each engineer and each project a budget — not to restrict, but to make costs visible. When everyone can see their own spend, behaviour changes naturally. People scope more carefully, choose the right model, kill runaway sessions earlier. Some engineers will come in under. Others will spike during intense debugging weeks. That's fine — the point is awareness, not enforcement.

*Visibility.* You can't manage what you can't see. Track spend per engineer, per project, per task type. Most providers break usage down by API key or workspace; assign keys per engineer or per pipeline and the data is already there. Put it on a dashboard the team can see — even a shared spreadsheet works to start. The engineer who sees a single debugging session cost as much as a week of normal work will scope tighter next time. You don't need to have a conversation about it. The number does the talking.

*Alerts and circuit breakers.* Set alerts at 50% and 80% of monthly budget so nobody gets surprised. More importantly, set hard per-session and per-job limits, especially for anything automated. A CI agent stuck in a retry loop at 3am is exactly how you get the "\$2,200 surprise bill" from the opening of this chapter. You don't need to catch every runaway session manually. Automated limits do the job.

*Cost as a quality signal.* High consumption on a task isn't just expensive — it's a sign something went wrong. Track cost per task type over time. If a category trends upward, investigate: prompts may have drifted, or the codebase has grown complex enough to need a different approach. If costs trend downward, that's your team getting better at agentic engineering. Cost data, used well, becomes a mirror for team skill.

=== The ROI Conversation

At some point, someone in management will ask what all this is buying. You need an answer, and it needs to be honest.

The tempting version goes: a senior engineer costs a lot; if agents make them 30% more productive, that's a big number; the tooling costs a small fraction of it; done. The arithmetic isn't wrong. The problem is the "if."

In mid-2025, METR ran a randomised controlled trial with experienced open-source developers working on their own mature repositories. With the AI tools of early 2025, they were about 19% _slower_ — while believing they'd been about 20% _faster_. The tools and the practices have moved on a lot since then, and one study of sixteen people doesn't settle anything. But the gap between perceived and measured speed should make every one of us humble. How fast it _feels_ is not evidence.

Google's DORA research from the same year adds the other half. AI adoption was near-universal among the teams surveyed, and the clearest finding was that AI acts as an _amplifier_. Teams with good tests, good review, and small batches got better. Teams with weak foundations got their weaknesses amplified — more code, faster, landing in a system that couldn't absorb it.

So have the conversation like an engineer:

- *Measure outcomes, not feelings.* Lead time from ticket to production, change failure rate, time to restore, review turnaround, escaped defects. Compare before and after. If the numbers don't move, the agents aren't paying for themselves yet, no matter how productive everyone feels.
- *Invest in the foundations.* The practices in this book — tests as a feedback loop, guardrails, conventions, the log — are what turn agent usage into outcomes. That's where the return comes from.
- *Be upfront about the learning curve.* Productivity can dip before it rises while people learn to scope, review, and delegate well.

The cost of the tools is rarely the hard part of the case. Proving they're working is. Do the measurement, and you'll have a story finance can trust — and one you can trust too.

== Privacy and Compliance

Some code genuinely cannot leave the building. This isn't paranoia — it's law.

Government contractors working on classified or export-controlled projects can't send source code to third-party APIs, full stop. The data residency requirements aren't suggestions. They come with criminal penalties.

Healthcare companies handling patient data are bound by HIPAA, GDPR, or equivalent regulations. If your code touches patient records — even test fixtures with realistic fake data that a compliance officer might squint at — you need to think carefully about what goes over the wire.

Financial institutions have their own maze of regulations. SOX, PCI-DSS, internal audit requirements — the specifics vary, but the theme is consistent: data stays inside controlled boundaries.

And then there's plain old competitive secrecy. Sending your proprietary algorithms to someone else's servers means trusting that they won't train on them, won't log them, won't get breached. Most commercial providers offer strong contractual guarantees here. But "strong contractual guarantees" and "impossible to breach" are different things, and some security teams aren't willing to accept the gap.

For all these cases, local models aren't a nice-to-have. They're the only option.

The trade-off is real: you're accepting reduced capability in exchange for absolute data control. But it's a much better trade than it was when the engineer in Munich was fighting with her model. A good open model doing a solid job on your regulated codebase is infinitely more useful than a frontier model you're not allowed to use. And for focused, well-scoped tasks — the kind you should be writing anyway — the gap is often smaller than you'd expect.

=== The Middle Ground: Private Deployments

There's a well-established middle path. Cloud providers offer frontier models inside your own cloud boundary, with contractual guarantees that your data stays there and isn't used for training — AWS Bedrock, Azure's OpenAI offering, and Google Cloud's Vertex AI all do versions of this. Claude Code, for instance, can run against Claude models through Bedrock or Vertex rather than Anthropic's own API.

This costs more and involves more procurement than a credit card and an API key. But for large organisations that need frontier capability and strict data control, it's increasingly the default answer: commercial model quality with most of the privacy guarantees of running locally.

== Model Routing in Practice

The real question isn't "local or commercial?" It's "which model, for which part of the workflow?"

A mature agentic setup routes different parts of the work to different models. This is hybrid in the truest sense — and it's where the ecosystem is heading.

=== The Routing Pattern

Think about what an agent actually does during a typical task:

+ *Exploration* — reading files, searching the codebase, understanding structure. High-volume, low-reasoning work.

+ *Planning* — analysing the problem, considering approaches, deciding on a strategy. This is where model quality matters most.

+ *Implementation* — writing the code changes, following the plan from step 2.

+ *Verification* — running tests, reading errors, deciding if the work is done. Moderate reasoning, heavy tool use.

+ *Iteration* — if verification fails, connecting the failure back to the implementation and adjusting.

Not all of these need the same model. Exploration can often go to a small, fast, cheap model — even a local one. Planning is where you want the frontier model; this is the reasoning that justifies the cost. Implementation and verification can often go to a mid-tier model, because the hard thinking is done and the model is executing a plan.

You'll see this pattern built into some tools already — for example, running exploration sub-agents on a smaller, faster model while a stronger model does the planning.
// v2-verify: confirm current tools still route exploration sub-agents to a smaller model (e.g. Claude Code's Explore sub-agent) before naming any.

=== What This Looks Like

In practice, routing can be as simple as configuring different models for different roles:

```
# Pseudocode — not real config; exact syntax depends on your tool
exploration_model:    "local/<open coding model>"   # Free, fast, good enough for reading
reasoning_model:      "<frontier model>"            # Best available reasoning for planning
implementation_model: "<fast mid-tier model>"       # Cheaper, follows plans well
```

Or it can be dynamic — a lightweight classifier that looks at the current step and routes accordingly. Some tools build this in. Others need you to wire it up yourself.

The economics are compelling. If most of an agent's tokens go on exploration and simple tasks, and you route those to a model that's an order of magnitude cheaper, you cut the bill substantially without touching quality on the parts that matter.

=== Routing for Privacy

Routing also solves the privacy problem more gracefully than all-or-nothing.

Say you're building a healthcare application. The data models and business logic touch patient data — that stays local. But the frontend components, the build configuration, the CI pipeline? No sensitive data there. There's no reason you can't use a frontier model for the non-sensitive parts and route sensitive work to a local one.

This needs tooling that's aware of sensitivity boundaries — which files can go external, which can't. That tooling is still maturing, and until it's there, the simplest version is organisational: separate repositories, separate sessions, separate permissions. Not "all local" or "all commercial," but "local where it matters, commercial everywhere else."

== Getting Started Without Paying the Farm

You don't need a big budget to start learning agentic engineering. You need a laptop and an evening. Here's a practical ramp.

=== The Local-First Path

If you have a machine with plenty of memory — 32GB is a comfortable starting point — you can run a useful coding model locally for free.

Install Ollama or LM Studio. Download a current open-weight coding model sized for your hardware; at the time of writing, the smaller mixture-of-experts coding models (Qwen3-Coder's 30B-A3B variant, or OpenAI's gpt-oss-20b) are sensible choices for a laptop.
// v2-verify: model examples current as of September 2026? Keep in sync with Appendix B.
Appendix B has the current recommendations. Then point an agent CLI that supports OpenAI-compatible endpoints at your local server — Codex CLI, opencode, Aider, Cline, and Goose all do.

You now have a real agentic setup: no API costs, no rate limits, no data leaving your machine.

It won't match a frontier model. Long sessions degrade faster, multi-file reasoning is weaker, and it's slower. But for focused, well-scoped tasks — "write tests for this function," "add error handling to this endpoint," "refactor this class to use dependency injection" — it's genuinely capable. And because it's free, you can iterate without watching the meter.

A practical starting stack:
- *Ollama or LM Studio* for model serving
- *A current open coding model* sized to your memory
- *An agent CLI that accepts a local endpoint*
- *A project with a test suite* — the agent needs feedback

Note what's not on that list: Claude Code. It's built for Anthropic's models and needs a paid Claude plan or an API key. There's no free tier.

=== The Sweet Spot: An Entry Subscription

When you're ready to spend money, the best value for most individuals is an entry-level subscription from one of the major vendors — around the price of a couple of lunches a month. That gets you a frontier-class model inside a proper agent tool, with usage limits that are fine for learning and for a good share of real work.

Pair it with a local model if you have the hardware. Use the subscription for what needs frontier capability — complex debugging, multi-file refactoring, planning. Use the local model for the high-volume, low-reasoning work. Your monthly bill stays flat and predictable.

If you find yourself hitting the usage limits every day, that's a signal — either you've found real value and it's time to move up a tier, or your sessions are sprawling and it's time to scope tighter. Usually it's a bit of both.

=== Scaling Up Intentionally

The mistake is starting with the most expensive option and optimising later. Start small. Learn the workflows. Understand where model quality actually matters and where "good enough" is good enough. Then spend money on the specific gaps.

By the time you're spending real money, you'll know exactly what you're paying for — and, more importantly, what you're _not_ paying for. That knowledge is worth more than any amount of credits.

== The Landscape Is Shifting

In the first edition I wrote that six months later, the specifics in this chapter would be out of date. They were. Open models caught up faster than I expected, pricing changed shape, and a few recommendations aged badly. This edition keeps the specifics in Appendix B for exactly that reason.

What hasn't changed is the framework. You still evaluate models along the same axes: capability, cost, privacy, speed, and reliability. You still match the model to the task rather than using one model for everything. You still stay flexible.

The engineers I see doing the best work aren't loyal to any particular model or deployment approach. They're pragmatists. They use the frontier model when the task demands it, a cheaper one when it's good enough, and a local one when privacy or cost requires it. They measure what works. They switch when something better comes along.

Don't get religious about this. The model is a tool. The skill is in knowing which tool to reach for — and that skill transfers regardless of which models exist six months from now.
