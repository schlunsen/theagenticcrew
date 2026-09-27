= Context

Not long ago, a bug came in from a customer: payments were silently failing for users with non-ASCII characters in their billing address. A tricky one — the kind that lives in the seam between your frontend validation and your payment gateway's character encoding.

An engineer on my team grabbed the ticket first. He opened his agent and typed: "There's a bug with payments for international users. Can you look into it?" The agent gamely read through the payments module, made some plausible guesses about Unicode handling, and produced a patch that normalised all input to ASCII. It would have stripped every accent, every umlaut, every character outside the English alphabet from every user's billing address. A fix that was technically worse than the bug.

An hour later, a second engineer picked up the same ticket after the first attempt was rejected in review. She pasted in the customer's error log, the failing Sentry trace, the specific payment gateway response code, the relevant section of the gateway's character encoding documentation, and the three files involved in the billing pipeline. Her agent diagnosed the issue in under two minutes: a UTF-8 string was being passed through a function that assumed Latin-1 encoding before hitting the gateway's API. The fix was four lines. It shipped that afternoon.

The model was the same. The agent was the same. The bug was the same. What differed was what each engineer put in front of the agent before asking it to work. One gave it a vague description and let it guess. The other gave it everything it needed to _see_ the problem.

But here's the thing: the second engineer didn't just give better context. She gave the agent the _raw materials_ it needed — the error trace, the docs, the relevant files. That's a significant step up. The even better version? Giving the agent _tools_ to find those materials itself. If that Sentry trace was accessible via an MCP integration, if the agent could read the gateway docs from a configured source, if it could run `git log` on the billing pipeline — she wouldn't have needed to hand-assemble the context at all. The agent would have gathered it, and she could have focused on what only she could provide: the judgment that this was a character encoding issue, not a validation issue.

That difference — what the agent can see, and what it can _reach_ — is what this chapter is about.

The single most important skill in agentic engineering isn't prompting. It's context engineering.

The industry settled on that name in 2025, and it's a good one. It covers everything that ends up in the model's window — instructions, tool definitions, files, retrieved data, conversation history — and treats curating it as an engineering discipline rather than a knack. An AI agent is only as good as what it can see. Give it a vague instruction and a blank slate, and it will hallucinate confidently. Give it the right files, the right constraints, the right view of the system — and it will do things that feel like magic. The difference isn't the model. It's you.

Traditional engineering had a version of this too. A senior engineer didn't just write better code — they held more of the system in their head. They knew which files mattered, where the dragons lived, which abstractions were load-bearing and which were decorative. That mental model was the context, and it lived entirely in the engineer's brain.

Now you have to _externalise_ it. Your agents can't read your mind. They read files, environment variables, error logs, and whatever you put in front of them — and increasingly, they can go _find_ those things if you give them the right tools. The craft is learning what to surface, when, and how — and, more importantly, building the infrastructure that lets agents surface things for themselves.

== The Context Window Is Your Workbench

Think of the context window as a physical workbench. It has limited space. You can't dump your entire codebase on it and expect good results. Instead, you lay out the pieces that matter for _this_ task: the relevant source files, the failing test, the schema, maybe a snippet of documentation.

But here's the evolution in thinking: you're not the surgeon's assistant, nervously handing over instruments one at a time. You're the person who _designed the operating room_. A good agentic engineer curates context, yes — but the real skill is building a well-organised workshop where the agent can find what it needs. Clear file structure, accessible tools, well-labelled drawers. When the workshop is set up right, the agent pulls the right instrument off the wall itself. You step in only when it needs something that isn't on any shelf — your judgment, your intent, your knowledge of why things are the way they are.

#image("../assets/illustrations/ch02-context-workbench.jpg", width: 80%)

This means developing instincts for questions like:
- What does the agent need to see to understand this task?
- What will confuse it if I include it?
- Is the context I'm providing _current_, or am I feeding it stale information?

== Context Infrastructure vs. Context Injection

There are two kinds of context that matter in agentic work — and most engineers only think about one of them.

*Context infrastructure* is the durable investment. It's everything you set up _once_ that pays off in every session: filesystem access, command execution, MCP integrations with your error tracker and project management tools, a well-organised repo, instruction files that describe your architecture and conventions. When you invest in infrastructure, you're building a workshop where the agent can find its own tools. This is _engineering_ — it compounds.

*Context injection* is the manual, per-session work: pasting in error logs, writing out constraints, explaining domain knowledge, describing intent. It's still essential — there are things no tool can discover, like why a particular design decision was made, or that the marketing team needs this feature by Thursday. But it should be the _fallback_, not the default. Every time you find yourself repeatedly pasting the same kind of information, that's a signal to promote it from injection to infrastructure by setting up a tool or integration.

The best agentic engineers spend most of their effort on infrastructure and inject only what is genuinely ephemeral or tacit. The rest spend all their time injecting and wonder why every session feels like starting from scratch.

=== The Ladder: Three Levels of Delivery

It helps to think about how context reaches your agent as a ladder, from least effective to most:

*Level 0: Describe the problem in your own words.* "The build is broken, something about types." This is the lossiest form of context. You're compressing a detailed error through the narrow pipe of your paraphrase, and the agent has to decompress it — badly — on the other side. It's like describing a painting to someone over the phone and asking them to reproduce it.

*Level 1: Paste raw data.* Copy the stack trace, the failing test output, the log file, the relevant source code. This is where most competent engineers land, and it's a meaningful step up. The agent sees exactly what you saw. No lossy compression. The limitation is that it's manual, it's ephemeral, and it doesn't scale — next session, you'll need to paste it all again.

*Level 2: Give the agent tools to find the data itself — and provide only what tools can't discover.* The agent runs the failing test, reads the error trace, greps for the relevant code, checks `git blame` for the history. You provide the _intent_ ("we need to fix this without changing the stored format because three downstream services depend on it") and the _constraints_ ("the payment gateway has a quirk that isn't documented anywhere"). This is where you should aim. It's durable, it scales, and it lets you focus on the part of the job that's actually hard: judgment.

Level 0 and Level 1 are injection. Level 2 is what infrastructure buys you. Most teams are somewhere between Level 0 and Level 1. The rest of this section is the path to Level 2.

=== Building the Infrastructure

*Give agents access to your tools.* File system access and command execution are the baseline. An agent that can run `git log`, `git blame`, `grep`, and your test suite can answer most of its own questions. But don't stop there. MCP servers can connect agents to external systems — your error tracker, your project management tool, your database, your CI pipeline. Each integration is one less thing you need to copy-paste manually, forever. (Each one also costs context just by being there, and each one is a new door for untrusted content — the Extending the Agent's Reach and Agent Attack Surface chapters cover both sides.)

*Make your project structure navigable.* A well-organised project _is_ context infrastructure. Meaningful file names, clear directory structure, a good README — these aren't just for humans anymore. Your agents read them too. When the filesystem is legible, a tool-equipped agent can find the right file without you pointing at it.

*Maintain agent instruction files.* A project-level file — `AGENTS.md`, which has become the cross-tool standard, or `CLAUDE.md` for Claude Code — that describes architecture, conventions, and current priorities persists across sessions and gets read automatically. We cover what makes a good one in the Convention Over Configuration chapter.

*Scope your tools, don't remove them.* The instinct to restrict agent access is understandable, but over-restricting is just as costly as over-permitting. Instead of preventing file access, scope it to the relevant directories. Instead of blocking command execution, allowlist the commands that matter. A well-scoped agent is both safe and capable. Scoping is also pruning: an agent debugging a rendering issue that can't wander into your authentication middleware won't fill its window with it.

=== What Only You Can Inject

Tools can't provide everything. Your mental model of why something was designed a certain way, constraints that were never written down, tribal knowledge about how the team works, domain expertise about the business — this is what _you_ bring.

*Give intent, not just locations.* A tool-equipped agent is surprisingly good at finding the right files. What it _can't_ find is your intent. "We need to fix the encoding bug in the billing pipeline, and the fix must not change the stored format because three downstream services depend on it" is the kind of context no tool can discover. Focus your manual input on the _why_ and the _constraints_, not the _where_.

*Raw data over paraphrase — always.* This is the most common mistake I see: engineers describing an error in their own words instead of providing the actual error. "The build is failing with some TypeScript error about types" versus the exact compiler output with file path, line number, and error code. If the agent can't run the build or pull the trace itself, paste the real thing. Never the summary.

*Interpret the history.* If your agent can run `git blame` and `git log`, it can find _what_ changed and _when_. What it still needs from you is the interpretation: "This function looks weird but it was written this way because of a payment gateway quirk that isn't documented anywhere — see `abc123`."

*Layer your briefing.* For complex tasks, start with the high-level picture — what the system does, what you're trying to change, why. Then point at the specific area. Then the error or test failure. This mirrors how you'd brief a human colleague, and it works for the same reason: it builds a mental model before diving into specifics.

*Consider speaking instead of typing.* When you need to inject intent, constraints, and domain knowledge, your voice is a remarkably efficient delivery mechanism. Speaking at 130 words per minute versus typing at 40 to 80 means you can narrate far more context in the same time. More importantly, the physical fatigue of typing acts as a silent filter that makes your prompts shorter and thinner as the day goes on. Speaking removes that filter. We cover this in depth in the Articulating Intent chapter, but the point is relevant here: the _medium_ you use to deliver context affects how much of it actually reaches the agent.

*Equip, don't spoon-feed.* When you catch yourself about to paste something for the third time, ask: could the agent have found this on its own if it had the right tools? If yes, invest the time in setting up that access instead. Pasting is a one-time fix. Tooling is a permanent upgrade. The goal is an agent that needs you for your judgment, not your clipboard.

=== Pre-load or Let It Fetch?

"Let the agent find it" is the right default, but it isn't dogma. There are two ways information can arrive in the window: _pre-loaded_ before the agent starts, or retrieved _just in time_ through a tool call when the agent decides it needs it.

Just-in-time retrieval keeps the window lean. The agent sees a directory listing, not every file; a list of available tools and skills, not their full documentation; the headline of a ticket, then the body if it turns out to matter. Loading summaries first and details on demand — progressive disclosure — is how the better agent tools now handle everything from instruction files to skills.

But every tool call is a round-trip: time, tokens, and a chance for the agent to go looking in the wrong place. So here's the nuance. When you _know_ the agent will need something — the failing test output for a "fix this test" task, the ticket body for a ticket-driven pipeline, the schema for a migration — fetch it deterministically and put it in front of the agent up front. It's cheaper and more reliable than hoping the agent thinks to ask. When you _don't_ know what it will need — exploratory debugging, an unfamiliar codebase, an open-ended investigation — give it tools and let it pull.

Pre-load what's certain. Provide tools for what's uncertain. The mistake is doing either one for everything.

== The Context Window Tax

Every token you put into a context window costs you twice: once in money, once in attention.

The money part is straightforward. Tokens are what you pay for, one way or another — directly on an API bill, or indirectly through the usage limits on a subscription. Dump your entire codebase into context and you're burning budget on every interaction.

The more insidious cost is attention. Language models don't treat all tokens equally — information in the middle of a long context tends to get less weight than information at the beginning or end. And performance doesn't just dip at the edges of the window; it degrades as input grows. Research in 2025 gave this a name — _context rot_ — and showed it happening well below the advertised limits. The more you stuff in, the more likely the model is to miss the thing that actually matters.

When context windows grew from tens of thousands of tokens to hundreds of thousands — and, for some frontier models, around a million — plenty of people assumed the problem was solved. Just put everything in. It wasn't solved. A bigger workbench doesn't make a messier one easier to work at. The tax got cheaper per token; it didn't go away.

I learned this the hard way. Early on, I thought more context was always better. Working on a tricky database migration, I fed the agent every migration file we'd ever written — three years of schema changes, hundreds of files. My reasoning was sound: the agent needed to understand the full history to write the next migration correctly. The result was a migration that duplicated a column that already existed, because the relevant earlier migration was buried in the middle of an enormous context and the model effectively lost track of it.

The next attempt, I gave it only the current schema, the three most recent migrations, and a one-paragraph summary of the relevant history. The agent nailed it.

That's the tax in action. There's a sweet spot between too little and too much, and finding it is a skill you develop through practice.

Too little context produces hallucination. The agent doesn't have enough information, so it fills in the gaps with plausible-sounding inventions. You ask it to fix a function without showing it the file, and it invents an API that doesn't exist. You ask it to write a test without showing it your test framework, and it picks Jest when you use Vitest.

Too much context produces confusion and waste. The agent has the answer buried somewhere in the pile, but it can't find it — or worse, it finds contradictory information across different files and picks the wrong one.

The sweet spot is _curated_ context. Not everything the agent could possibly need, but everything it actually needs for this specific task, laid out clearly. Think of it less like filling a filing cabinet and more like briefing a colleague before a meeting. You wouldn't hand them every document the company has ever produced. You'd hand them the three things they need to read and a one-minute summary of the background.

A practical heuristic: if you're about to put something into context, ask yourself — will the agent make a different (better) decision because it saw this? If the answer is no, leave it out.

== Keeping the Window Clean

Curating what goes _in_ is half the job. The other half is managing what accumulates during a long piece of work — file reads, test output, dead ends, abandoned theories. A session that started with a crisp window can be mostly noise two hours later. The techniques for dealing with this have matured, and they're worth knowing by name.

*Compaction.* Summarise the session so far into a short brief, and carry on in a fresh window seeded with that brief instead of the full transcript. Most agent tools now do this — Claude Code has a `/compact` command and compacts automatically as the window fills. Automatic compaction is a safety net, not a strategy: the summary is only as good as the model's guess about what mattered. When you know what matters, compact deliberately and tell it what to keep.

*Structured note-taking.* Have the agent write its progress to a file — a plan, a checklist, a running `NOTES.md` — and re-read it as it goes. Notes live outside the window, so they survive compaction and session boundaries intact. It's the same trick a human uses on a long task: don't hold it in your head, write it down.

*Sub-agents for isolation.* When a task needs a lot of exploration — "find every place we construct a payment request" — hand it to a sub-agent with its own window. It reads fifty files, and returns a condensed answer: the six call sites that matter and what's odd about two of them. Your main session gets the conclusion without the fifty files. This is the single most effective way I know to keep a long session sharp.

*Stay well below the limit.* Don't treat the window size as a target. A session running near its limit is a session in the zone where context rot bites hardest. Aim to keep utilisation comfortably low and reset before you need to.

These combine into a workflow that has become common for any non-trivial change: *research → plan → implement*, with a fresh or compacted context between each phase.

+ *Research.* The agent (often via sub-agents) explores the code and relevant systems and writes up what it found: the files involved, how they fit together, the constraints.
+ *Plan.* In a clean context seeded with the research notes, the agent writes a concrete plan — which files change, in what order, how it will be verified. You review this. It's far cheaper to correct a plan than a diff.
+ *Implement.* In another clean context, seeded with the plan, the agent does the work — checking off steps in the plan file as it goes.

Each phase starts with a small, dense, relevant window instead of inheriting the debris of the last one. Plan modes in agent tools, and the spec-driven tools that appeared in 2025, are variations on the same idea. The Articulating Intent chapter goes deeper on the planning half.

== Where the Agent Works

Context isn't just about text in a prompt. It's about _where_ your agent operates and what it can reach.

The simplest setup is the local machine: the agent runs in your project directory, reads your files, runs your commands. The advantage is immediacy — it sees what you see. The risk is equally obvious: it's your machine, your credentials, your production config sitting right there in `~/.env`. The alternative is a sandbox — a worktree, a container, a VM, or a cloud environment — where a mistake is cheap and your keys aren't lying around. The Guardrails chapter covers the sandbox spectrum and the Git chapter covers worktrees; here, the point is simply that the environment _is_ context. What the agent can reach defines what it can know.

=== Remote Exploration

This is where things get interesting. A skilled agentic engineer doesn't just point agents at local files — they teach agents to _explore_ remote systems.

SSH into a staging server to examine logs. Query a database to understand the shape of real data. Curl an API endpoint to see what it actually returns, not what the docs claim it returns. Pull down container logs from a running service.

The agent becomes your scout. You point it at a system and say: "go look around and tell me what you find." This is also a perfect job for a sub-agent: let it wade through the logs in its own window and bring back the three lines that matter. But you have to set this up. The agent needs credentials (scoped and temporary), network access, and clear boundaries on what it's allowed to touch.

This is a judgement call — how much access to give, to which systems, with what guardrails. Too little and the agent is useless. Too much and you're one bad prompt away from a production incident. And remember that everything the agent reads out there — log lines, API responses, ticket text — is content you didn't write. The Agent Attack Surface chapter explains why that matters. The agentic engineer learns to calibrate this over time.

== Context Across Sessions

Context windows are ephemeral. When a session ends, everything the agent learned vanishes. Compaction stretches a session further, but it's lossy, and it doesn't help tomorrow morning. Real engineering work spans days, sometimes weeks. If you don't plan for session boundaries, you'll waste enormous time re-establishing context the agent already had.

The immediate solution is to make context _durable_ through the codebase itself:

*Commit early and often.* Every commit is a checkpoint that future sessions can reference. Good commit messages become the breadcrumb trail: "Refactored payment gateway to separate encoding step — next step is to add tests for non-ASCII input." A session that ends with uncommitted changes is a session whose context is trapped in a terminal window that might not exist tomorrow.

*Keep the notes.* The plan files and progress notes from structured note-taking are exactly what the next session needs. When you finish a complex session, have the agent update them — what it accomplished, what's left, what it learned — and leave them where the next session will look: in the repo, or on the ticket. You've preserved hours of accumulated understanding in a few paragraphs.

*Promote what's permanent.* If a session taught you something every future session needs — "never use the ORM here", "the staging database is shared, don't truncate tables" — it doesn't belong in a note. It belongs in the instruction file.

Many agent tools now also offer some form of built-in memory that carries facts between sessions. It's useful, but it's still the beginning of the answer. The deeper version — memory systems that capture and retrieve knowledge deliberately, across sessions and across a team — is the subject of the Ship's Log chapter.

== Context as Architecture

As you get better at agentic engineering, you start designing your systems _for_ context. File naming, directory structure, and conventions all serve double duty — they help humans _and_ they help agents navigate. The Convention Over Configuration chapter covers these structural choices in depth. Here, let's focus on the context dimensions that are unique to code architecture.

*Small functions are context-friendly.* A 400-line function requires the agent to hold the entire thing in working memory. A 30-line function that does one thing is something the agent can understand completely, modify confidently, and verify quickly. Every time you extract a well-named function from a larger one, you're creating a unit of meaning that an agent can work with independently.

*Monorepos vs. multirepos: a context tradeoff.* In a monorepo, the agent can see everything — powerful for cross-boundary tasks, but it might see _too much_. In a multirepo setup, each repo is naturally scoped, but cross-service tasks become harder. Neither is universally better. The point is that your repo strategy is a context decision, whether you think of it that way or not.

*Types are context.* A strongly typed codebase gives agents a machine-readable description of every function's contract. TypeScript, Rust, Go — these languages carry structural context in their type systems. Python and JavaScript leave the agent guessing unless you've written thorough docstrings or type hints. Type systems do double duty in the agentic era: they catch bugs _and_ they communicate intent.

*Documentation is ground truth (whether it's accurate or not).* Agents treat your README, your API docs, your inline comments as authoritative. If your docs say the API returns a `user_id` field but the actual response returns `userId`, the agent will write code against the documentation and produce a bug. Stale documentation was always a nuisance. With agents, it's an active source of defects — because agents follow bad docs more faithfully than a human would.

The way you structure your code, your repos, your infrastructure — it all becomes part of the context you're providing to your crew. The engineers who understand this early will build systems that are not just maintainable by humans, but _navigable_ by agents.
