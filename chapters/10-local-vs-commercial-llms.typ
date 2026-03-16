= Local LLMs vs. Commercial LLMs

A friend of mine — senior engineer at a Series B startup — pinged me on a Friday afternoon. "I just got our first real API bill. Twenty-two hundred dollars. For _March_." He'd been running Claude Code across his team of eight engineers, each of them iterating on features, debugging, refactoring. Nobody had set token budgets. Nobody was watching the meter. The agents worked beautifully, and the invoice was eye-watering.

That same week, I talked to an engineer at a healthcare company in Munich. She was running Llama 70B on a local GPU server because their patient data pipeline couldn't touch external APIs. Not "shouldn't" — _couldn't_. Their compliance team had made that clear in writing. She was getting decent results for focused tasks, but every time she needed complex multi-file reasoning, the model fell apart and she found herself doing the work manually.

These two stories are the bookends of the same question: where does the model run? It sounds like an infrastructure decision. It's really a decision about trust, cost, capability, and — increasingly — how you architect your entire agentic workflow.

== Commercial LLMs: The Frontier

Commercial models — Claude, GPT, Gemini — are where the frontier lives. If you're doing serious agentic engineering, you've probably spent most of your time here. There are good reasons for that.

=== Context Windows

Context is everything for agents. An agent doesn't just read your prompt — it reads files, tool outputs, error messages, test results, and its own previous reasoning. A single complex task can easily fill 50,000 tokens of context, and a multi-step debugging session can blow past 100,000.

Frontier commercial models offer context windows of 128K tokens and beyond. This matters enormously for agentic work because the agent needs to hold your codebase in its head. When context runs out, the agent starts forgetting earlier files it read, earlier decisions it made, earlier errors it saw. It degrades from a capable engineer into someone with amnesia.

Local models typically top out at 8K–32K context in practice, even if they technically support more on paper. The quality of attention degrades as you push toward the limit. A commercial model at 100K context is still reasoning well. A local model at 32K context is often losing the thread.

=== Tool Use Quality

Agents live and die by tool use. Reading files, writing code, running commands, searching codebases — these aren't optional extras. They're the core loop. And the quality of tool use varies dramatically between models.

Frontier commercial models have been specifically trained and tuned for tool calling. They format arguments correctly, they chain tool calls logically, they recover gracefully when a tool call fails. They know when to read a file before editing it. They know when to run tests after making changes.

Smaller models — including most local models — are less reliable here. They'll hallucinate file paths, forget to pass required arguments, call tools in the wrong order, or get stuck in loops calling the same failing tool over and over. The difference isn't subtle. On a complex task involving ten or fifteen tool calls, a frontier model might succeed 90% of the time where a local model succeeds 40%.

=== Instruction Following

When you tell a frontier model "only modify files in the `src/auth/` directory" or "don't change the public API, only the internal implementation," it generally listens. It follows system prompts, respects constraints, and stays within boundaries.

Smaller models drift. They'll start well, then gradually ignore your constraints as the conversation gets longer and the context fills up. This is a real problem for agentic work, where precision matters. An agent that "mostly" follows instructions will occasionally rewrite a file you didn't ask it to touch, or refactor something you explicitly told it to leave alone. In a sandboxed environment this is just annoying. Without a sandbox it's dangerous.

=== Choosing the Right Commercial Model

Not all commercial models are interchangeable, even at the frontier. Here's what I've found in practice:

*For complex multi-file refactoring and architectural work* — use the most capable model you can afford. This is where reasoning quality matters most. The cost difference between a mid-tier and top-tier model is a few dollars per task. The quality difference is often the difference between a clean diff and a mess you have to redo manually.

*For focused single-file tasks* — writing tests, implementing a well-defined function, fixing a clear bug — mid-tier models perform almost as well as top-tier ones, at a fraction of the cost. The task is scoped enough that the model doesn't need to juggle many concerns at once.

*For high-volume, low-complexity work* — generating boilerplate, formatting code, writing commit messages — the cheapest model that can follow instructions is the right choice. You'll run these tasks hundreds of times. The per-token savings compound.

The mistake I see most often is using a single model for everything. That's like driving a Formula 1 car to the grocery store. Match the model to the task.

== Local LLMs: The Full Picture

Running a model locally — Llama, Mistral, Qwen, DeepSeek, Codestral, or any of the open-weight models via Ollama, llama.cpp, or vLLM — gives you something commercial APIs cannot: complete data sovereignty and zero marginal cost per token.

Your code never leaves your machine. You can feed it proprietary source, internal documents, production logs, customer data, API keys you accidentally left in a config — none of it crosses a network boundary. And once the model is downloaded, every inference is free. Run it a thousand times, run it all night, nobody sends you a bill.

But let's be honest about the experience, because the marketing around local models often isn't.

=== The Hardware Reality

The hardware question is the first one everyone asks, and the answer is less glamorous than the "run AI locally!" blog posts suggest.

*MacBook Pro with Apple Silicon (M2/M3/M4 Pro or Max, 32–64GB RAM).* This is the sweet spot for individual developers. You can run a 7B–14B parameter model comfortably, and a 32B model if you have the RAM. Inference will be noticeably slower than a commercial API — maybe 15–30 tokens per second for a 14B model, compared to 80+ from a commercial API. A 70B model will technically run on a 64GB machine but it'll be slow enough to test your patience. You'll be waiting 10–20 seconds for responses that take 2 seconds from an API.

*Dedicated GPU server (NVIDIA RTX 4090 or A100).* This is where local inference gets genuinely fast. A 4090 with 24GB VRAM can run a 14B model at near-commercial speeds. An A100 with 80GB can run a 70B model comfortably. But now you're maintaining hardware. You're dealing with CUDA drivers, VRAM management, and the occasional "why is my GPU fan screaming at 3am" incident.

*Consumer hardware (16GB MacBook Air, older machines, no discrete GPU).* You're limited to 7B models, and the experience will be mediocre. Inference is slow, the models are too small for serious agentic work, and you'll spend more time waiting than working. I wouldn't recommend this for anything beyond experimentation.

The honest summary: local models are practical for developers with a recent MacBook Pro or a dedicated GPU. Below that hardware threshold, you'll have a frustrating experience. Above it, you'll have a genuinely useful tool — just a different tool than a commercial API.

=== Where Local Models Shine

Local models aren't just "worse commercial models." There are workflows where they genuinely make more sense:

*High-frequency, low-stakes tasks.* Generating docstrings, writing commit messages, creating boilerplate code, formatting data. These tasks don't need a genius model — they need a fast, free model. Running them locally means you can fire-and-forget without thinking about cost.

*Sensitive codebases.* We'll cover this more in the privacy section, but this is a legitimate and growing use case. If your code can't leave your network, local models are the only option, and "good enough" is infinitely better than "not available."

*Offline development.* On a plane, on a train, in a bunker — your local model works without WiFi. This sounds minor until you're on a twelve-hour flight trying to debug something.

*Experimentation and learning.* When you're experimenting with agent frameworks, testing prompt strategies, or building custom tool integrations, burning API credits on trial-and-error feels wasteful. A local model lets you iterate freely.

=== Where Local Models Struggle

It's worth being specific about the failure modes, because "it's less capable" is too vague to be useful.

*Multi-file reasoning.* Ask a local 14B model to trace a bug across four files and a database schema, and it'll lose the plot. It might find the right file but misunderstand the interaction between components. This is the biggest practical gap.

*Long-horizon tasks.* Agentic tasks that involve many steps — read, plan, implement, test, debug, iterate — require the model to maintain coherent intent across a long context. Local models tend to drift. They forget the plan. They revisit decisions they already made. They get stuck in loops.

*Nuanced code review.* "This code is correct but the approach is wrong" is a judgement call that requires deep understanding. Local models tend toward surface-level analysis — they'll catch syntax issues and obvious bugs but miss architectural problems.

*Complex tool orchestration.* When a task requires ten or more chained tool calls — reading a test file, running it, reading the error, finding the source file, understanding the context, making a change, running the test again — local models stumble more frequently at each step, and the error rate compounds.

None of this means local models are useless. A 32B model running locally can handle a surprising range of well-scoped tasks. But you need to scope the tasks accordingly. Asking a local model to do what a frontier model does is setting it up to fail.

== The Cost of Agentic Work

Here's a number that surprises people: a single agentic coding session can easily consume 100,000–500,000 tokens. Not because you're chatting — because the agent is _working_.

Consider what happens when an agent tackles a moderately complex bug fix. It reads three or four files to understand the context (maybe 8,000 tokens of input). It reasons about the problem (2,000 tokens of output). It reads two more files (4,000 tokens). It writes a fix (1,000 tokens). It runs the tests (tool call, 500 tokens of output). The tests fail. It reads the error (1,000 tokens). It revises the fix (1,500 tokens). It runs the tests again. They pass. It reads the diff to double-check (1,000 tokens). Total: maybe 25,000 tokens for a straightforward bug fix.

Now consider a complex refactoring task. The agent might read twenty files, generate a plan, implement changes across eight files, run the test suite four times, debug two regressions, and write new tests. That's easily 200,000 tokens. At frontier model pricing, that's somewhere between \$3 and \$15 depending on the model and the input/output ratio.

Here are rough cost ranges I've seen in practice, based on using frontier commercial models:

- *Simple bug fix or small feature:* \$0.30–\$1.00
- *Moderate feature with tests:* \$2–\$5
- *Complex multi-file refactor:* \$5–\$15
- *Large feature implementation:* \$15–\$40+
- *Exploratory debugging session that goes long:* \$10–\$30

Multiply these numbers by a team of engineers, each running several agentic tasks per day, and you're looking at real money. My friend's \$2,200 bill? That's about right for eight active engineers.

=== Strategies for Managing Cost

The solution isn't to stop using agents. It's to be smart about it.

*Set token budgets.* Most agent frameworks let you set a maximum token limit per task. This isn't just cost control — it's also a quality signal. If an agent burns 500,000 tokens on a task that should take 50,000, something has gone wrong. The agent is stuck, looping, or misunderstanding the task. A budget forces it to fail fast rather than spiral.

*Use model routing.* Don't send every task to the most expensive model. We'll dig into this more in the next section, but the short version: use a cheap, fast model for exploration and code reading, and a capable expensive model for reasoning and implementation. This alone can cut costs by 50–70%.

*Cache aggressively.* If your agent framework supports prompt caching, turn it on. Much of an agent's context is repeated between turns — the same system prompt, the same project context, the same recently-read files. Caching avoids re-processing those tokens on every turn.

*Scope tasks tightly.* A well-scoped task ("fix the timezone bug in `billing/invoice.py`, the test is in `tests/test_invoice.py`") is cheaper than a vague one ("fix the billing bugs"). Scoping isn't just good engineering — it's cost control. The agent reads fewer files, makes fewer exploratory tool calls, and converges faster.

*Review your failures.* When a task fails or takes way too many tokens, figure out why. Was the prompt vague? Was the agent missing context it needed? Was the model not capable enough for the task? Each failure is a tuning opportunity.

== Privacy and Compliance

Some code genuinely cannot leave the building. This isn't paranoia — it's law.

Government contractors working on classified or export-controlled projects can't send source code to third-party APIs, full stop. The data residency requirements aren't suggestions. They come with criminal penalties.

Healthcare companies handling patient data are bound by HIPAA, GDPR, or equivalent regulations. If your code touches patient records — even test fixtures with realistic fake data that a compliance officer might squint at — you need to think carefully about what goes over the wire.

Financial institutions have their own maze of regulations. SOX compliance, PCI-DSS, internal audit requirements — the specifics vary, but the theme is consistent: data stays inside controlled boundaries.

And then there's plain old competitive secrecy. Your proprietary algorithms, your secret sauce, your competitive advantage — sending that to someone else's servers requires trusting that they won't train on it, won't log it, won't get breached. Most commercial API providers offer strong contractual guarantees about this. But "strong contractual guarantees" and "impossible to breach" are different things, and some security teams aren't willing to accept the gap.

For all these cases, local models aren't a nice-to-have. They're the only option.

The trade-off is real: you're accepting reduced model capability in exchange for absolute data control. A local 32B model doing a mediocre job on your classified codebase is infinitely more useful than a frontier model you're not allowed to use. And for focused, well-scoped tasks — the kind you should be writing anyway — the quality gap is often smaller than you'd expect.

=== The Middle Ground: Private Deployments

It's worth noting there's an emerging middle path. Cloud providers now offer private model deployments — dedicated instances of frontier models running inside your VPC, with contractual guarantees that your data stays in your boundary and isn't used for training. AWS Bedrock, Azure OpenAI, Google Cloud's Vertex AI all offer versions of this.

These aren't cheap. You're paying for dedicated compute, not shared API infrastructure. But for large organisations that need frontier capability and strict data control, this is increasingly the answer. You get commercial model quality with local model privacy guarantees — for a price.

== Model Routing in Practice

Here's where the conversation gets interesting. The question isn't "local or commercial?" It's "which model, for which part of the workflow?"

A sophisticated agentic setup routes different parts of the workflow to different models. This isn't theoretical — teams are doing this today, and it's the direction the ecosystem is moving.

=== The Routing Pattern

Think about what an agent actually does during a typical task:

+ *Exploration* — reading files, searching the codebase, understanding structure. This is high-volume, low-reasoning work. The model needs to decide which files to read and extract relevant information, but it's not doing deep thinking.

+ *Planning* — analysing the problem, considering approaches, deciding on a strategy. This requires strong reasoning. It's the part where model quality matters most.

+ *Implementation* — writing the actual code changes. This requires good code generation and the ability to follow the plan from step 2.

+ *Verification* — running tests, reading errors, deciding if the work is done. Moderate reasoning, heavy tool use.

+ *Iteration* — if verification fails, going back and adjusting. This requires understanding the failure and connecting it back to the implementation.

Not all of these steps need the same model. Step 1 can be handled by a small, fast, cheap model — even a local one. It's reading files and reporting what's in them. Step 2 is where you want the frontier model — this is the expensive reasoning that justifies the API cost. Steps 3–5 can often be handled by a mid-tier model, since the hard thinking is already done and the model is executing a plan.

=== What This Looks Like

In practice, model routing can be as simple as configuring your agent framework to use different models for different task types:

```
# Pseudocode — the exact config depends on your framework
exploration_model: "local/qwen-14b"       # Free, fast, good enough for reading
reasoning_model: "claude-sonnet"           # Frontier reasoning for planning
implementation_model: "claude-haiku"       # Fast, cheap, follows plans well
```

Or it can be dynamic — a lightweight classifier that looks at the current step and routes accordingly. Some frameworks are starting to build this in natively. Others require you to wire it up yourself.

The economics are compelling. If 60% of an agent's tokens are spent on exploration and simple tasks, and you route those to a model that's 10x cheaper, you've cut your overall cost by more than half without any reduction in quality on the parts that matter.

=== Routing for Privacy

Model routing also solves the privacy problem more gracefully than an all-or-nothing approach.

Say you're building a healthcare application. The data models and business logic touch patient data — that needs to stay local. But the frontend components, the build configuration, the CI pipeline? Those don't contain sensitive data. There's no reason you can't use a frontier commercial model for the non-sensitive parts while routing sensitive work to a local model.

This requires tooling that's aware of sensitivity boundaries — which files can go external, which can't. That tooling is still maturing, but the pattern is clear. Instead of "all local" or "all commercial," you get "local where it matters, commercial everywhere else."

== The Landscape Is Shifting

Six months from now, the specifics in this chapter will be out of date. The cost numbers will change. The capability gaps will narrow. A new model will come out that reshuffles the rankings. This is the one prediction I'll make with confidence.

What won't change is the framework for thinking about it. You'll still need to evaluate models along the same axes: capability, cost, privacy, speed, and reliability. You'll still need to match the model to the task rather than picking one model and using it for everything. You'll still need to stay flexible.

The engineers I see doing the best work aren't loyal to any particular model or deployment approach. They're pragmatists. They use the frontier commercial model when the task demands it, a mid-tier model when it's good enough, and a local model when privacy or cost requires it. They measure what works. They switch when something better comes along.

Don't get religious about this. The model is a tool. The skill is in knowing which tool to reach for — and that skill transfers regardless of which models exist six months from now.
