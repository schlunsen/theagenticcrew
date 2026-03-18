= Context

Last month, a bug came in from a customer: payments were silently failing for users with non-ASCII characters in their billing address. A tricky one — the kind that lives in the seam between your frontend validation and your payment gateway's character encoding.

An engineer on my team grabbed the ticket first. He opened his agent and typed: "There's a bug with payments for international users. Can you look into it?" The agent gamely read through the payments module, made some plausible guesses about Unicode handling, and produced a patch that normalised all input to ASCII. It would have stripped every accent, every umlaut, every character outside the English alphabet from every user's billing address. A fix that was technically worse than the bug.

An hour later, a second engineer picked up the same ticket after the first attempt was rejected in review. She pasted in the customer's error log, the failing Sentry trace, the specific payment gateway response code, the relevant section of the gateway's character encoding documentation, and the three files involved in the billing pipeline. Her agent diagnosed the issue in under two minutes: a UTF-8 string was being passed through a function that assumed Latin-1 encoding before hitting the gateway's API. The fix was four lines. It shipped that afternoon.

The model was the same. The agent was the same. The bug was the same. What differed was what each engineer put in front of the agent before asking it to work. One gave it a vague description and let it guess. The other gave it everything it needed to _see_ the problem.

But here's the thing: the second engineer didn't just give better context. She gave the agent the _raw materials_ it needed — the error trace, the docs, the relevant files. That's a significant step up. The even better version? Giving the agent _tools_ to find those materials itself. If that Sentry trace was accessible via an MCP integration, if the agent could read the gateway docs from a configured source, if it could run `git log` on the billing pipeline — she wouldn't have needed to hand-assemble the context at all. The agent would have gathered it, and she could have focused on what only she could provide: the judgment that this was a character encoding issue, not a validation issue.

That difference — what the agent can see, and what it can _reach_ — is what this chapter is about.

The single most important skill in agentic engineering isn't prompting. It's context management.

An AI agent is only as good as what it can see. Give it a vague instruction and a blank slate, and it will hallucinate confidently. Give it the right files, the right constraints, the right view of the system — and it will do things that feel like magic. The difference isn't the model. It's you.

Traditional engineering had a version of this too. A senior engineer didn't just write better code — they held more of the system in their head. They knew which files mattered, where the dragons lived, which abstractions were load-bearing and which were decorative. That mental model was the context, and it lived entirely in the engineer's brain.

Now you have to _externalise_ it. Your agents can't read your mind. They read files, environment variables, error logs, and whatever you put in front of them — and increasingly, they can go _find_ those things if you give them the right tools. The craft of agentic engineering is learning what to surface, when, and how — and, more importantly, building the infrastructure that lets agents surface things for themselves.

== The Context Window Is Your Workbench

Think of the context window as a physical workbench. It has limited space. You can't dump your entire codebase on it and expect good results. Instead, you lay out the pieces that matter for _this_ task: the relevant source files, the failing test, the schema, maybe a snippet of documentation.

But here's the evolution in thinking: you're not the surgeon's assistant, nervously handing over instruments one at a time. You're the person who _designed the operating room_. A good agentic engineer curates context, yes — but the real skill is building a well-organised workshop where the agent can find what it needs. Clear file structure, accessible tools, well-labelled drawers. When the workshop is set up right, the agent pulls the right instrument off the wall itself. You step in only when it needs something that isn't on any shelf — your judgment, your intent, your knowledge of why things are the way they are.

#image("../assets/illustrations/ch02-context-workbench.jpg", width: 80%)

This means developing instincts for questions like:
- What does the agent need to see to understand this task?
- What will confuse it if I include it?
- Is the context I'm providing _current_, or am I feeding it stale information?

== Context Infrastructure vs. Context Injection

Before we get into the mechanics, it's worth naming the two layers of context that matter in agentic work — because most engineers only think about one of them.

*Layer 1: Context Infrastructure.* This is the durable investment. It's everything you set up _once_ that pays off in every session: filesystem access, command execution, MCP integrations with your error tracker and project management tools, well-organised repo structure, `CLAUDE.md` files that describe your architecture and conventions. When you invest in context infrastructure, you're building a workshop where the agent can find its own tools. This is _engineering_ — it compounds.

*Layer 2: Context Injection.* This is the manual, per-session work: pasting in error logs, writing out constraints, explaining domain knowledge, describing intent. It's still essential — there are things no tool can discover, like why a particular design decision was made, or that the marketing team needs this feature by Thursday. But it should be the _fallback_, not the default. Every time you find yourself repeatedly pasting the same kind of information, that's a signal to promote it from Layer 2 to Layer 1 by setting up a tool or integration.

The best agentic engineers spend most of their effort on Layer 1 and need Layer 2 only for things that are genuinely ephemeral or tacit. The rest spend all their time on Layer 2 and wonder why every session feels like starting from scratch.

=== Levels of Context Delivery

There's a useful way to think about how context reaches your agent, from least effective to most:

*Level 0: Describe the problem in your own words.* "The build is broken, something about types." This is the lossiest form of context. You're compressing a detailed error through the narrow pipe of your paraphrase, and the agent has to decompress it — badly — on the other side. It's like describing a painting to someone over the phone and asking them to reproduce it.

*Level 1: Paste raw data.* Copy the stack trace, the failing test output, the log file, the relevant source code. This is where most competent engineers land today, and it's a meaningful step up. The agent sees exactly what you saw. No lossy compression. The limitation is that it's manual, it's ephemeral, and it doesn't scale — next session, you'll need to paste it all again.

*Level 2: Give the agent tools to find the data itself — and provide only what tools can't discover.* The agent runs the failing test, reads the error trace, greps for the relevant code, checks `git blame` for the history. You provide the _intent_ ("we need to fix this without changing the stored format because three downstream services depend on it") and the _constraints_ ("the payment gateway has a quirk that isn't documented anywhere"). This is where you should aim. It's durable, it scales, and it lets you focus on the part of the job that's actually hard: judgment.

Most teams are somewhere between Level 0 and Level 1. The goal of this chapter is to get you to Level 2 — or at least to show you the path there.

== The Context Window Tax

Every token you put into a context window costs you twice: once in money, once in attention.

The money part is straightforward. API calls are priced by token count. Dump your entire codebase into context and you're burning dollars on every interaction. But the more insidious cost is attention degradation. Language models don't treat all tokens equally — there's a well-documented phenomenon where information in the middle of a long context gets less weight than information at the beginning or end. The more you stuff in, the more likely the model is to miss the thing that actually matters.

I learned this the hard way. Early on, I thought more context was always better. Working on a tricky database migration, I fed the agent every migration file we'd ever written — three years of schema changes, hundreds of files. My reasoning was sound: the agent needed to understand the full history to write the next migration correctly. The result was a migration that duplicated a column that already existed, because the relevant earlier migration was buried in the middle of an enormous context and the model effectively lost track of it.

The next attempt, I gave it only the current schema, the three most recent migrations, and a one-paragraph summary of the relevant history. The agent nailed it.

This is the context window tax in action. There's a sweet spot between too little and too much, and finding it is a skill you develop through practice.

Too little context produces hallucination. The agent doesn't have enough information, so it fills in the gaps with plausible-sounding inventions. You ask it to fix a function without showing it the file, and it invents an API that doesn't exist. You ask it to write a test without showing it your test framework, and it picks Jest when you use Vitest.

Too much context produces confusion and waste. The agent has the answer buried somewhere in the pile, but it can't find it — or worse, it finds contradictory information across different files and picks the wrong one. You're also paying for every token of noise you included.

The sweet spot is _curated_ context. Not everything the agent could possibly need, but everything it actually needs for this specific task, laid out clearly. Think of it less like filling a filing cabinet and more like briefing a colleague before a meeting. You wouldn't hand them every document the company has ever produced. You'd hand them the three things they need to read and a one-minute summary of the background.

A practical heuristic: if you're about to paste something into context, ask yourself — will the agent make a different (better) decision because it saw this? If the answer is no, leave it out.

== Local, Sandboxed, Remote: Moving Your Agents Around

Context isn't just about text in a prompt. It's about _where_ your agent operates and what it has access to.

=== The Local Machine

The simplest setup: the agent runs on your machine, reads your files, executes your commands. This is where most people start — tools like Claude Code operating directly in your project directory.

The advantage is immediacy. The agent sees what you see. It can read your code, run your tests, check your git history. The risk is also obvious: it's your machine, your credentials, your production config sitting right there in `~/.env`.

=== Sandboxed Environments

A more disciplined approach is to give the agent a sandbox — a container, a VM, a worktree. It gets a copy of the code but not your keys. It can break things without breaking _your_ things.

This matters more than most people realise. When you let an agent iterate freely — running code, installing packages, modifying files — you want it to do that in a space where a mistake is cheap. A sandboxed agent is a fearless agent, and a fearless agent is a productive one.

Worktrees are an underappreciated tool here. Git worktrees let you spin up an isolated copy of your repo in seconds. The agent works in its own branch, its own directory. If the result is good, you merge it. If not, you delete the worktree and move on. No mess.

=== Remote Exploration

This is where things get interesting. A skilled agentic engineer doesn't just point agents at local files — they teach agents to _explore_ remote systems.

SSH into a staging server to examine logs. Query a database to understand the shape of real data. Curl an API endpoint to see what it actually returns, not what the docs claim it returns. Pull down container logs from a running service.

The agent becomes your scout. You point it at a system and say: "go look around and tell me what you find." But you have to set this up. The agent needs credentials (scoped and temporary), network access, and clear boundaries on what it's allowed to touch.

This is a judgement call — how much access to give, to which systems, with what guardrails. Too little and the agent is useless. Too much and you're one bad prompt away from a production incident. The agentic engineer learns to calibrate this over time.

== Feeding Context Deliberately

There are two tiers to providing context, and the best agentic engineers invest heavily in the first so they rarely need the second.

=== Tier 1: Context Infrastructure

The highest-leverage thing you can do is give your agent _tools_ to gather context on its own. This is durable investment — you set it up once and every future session benefits.

*Give agents access to your tools.* File system access and command execution are the baseline. An agent that can run `git log`, `git blame`, `grep`, and your test suite can answer most of its own questions. But don't stop there. MCP servers can connect agents to external systems — your error tracker (Sentry, Datadog), your project management tool (Linear, Jira), your database, your CI pipeline. Each integration is one less thing you need to copy-paste manually, forever.

*Make your project structure navigable.* A well-organised project _is_ context infrastructure. Meaningful file names, clear directory structure, a good README — these aren't just for humans anymore. Your agents read them too. When the filesystem is legible, a tool-equipped agent can find the right file without you pointing at it.

*Maintain CLAUDE.md files (or their equivalent).* A project-level context file that describes architecture, conventions, and current priorities is one of the cheapest and most powerful forms of context infrastructure. It lives in the filesystem, persists across sessions, and gets read automatically. Think of it as a briefing document that every new agent session picks up on its own.

*Scope your tools, don't remove them.* The instinct to restrict agent access is understandable, but over-restricting is just as costly as over-permitting. Instead of preventing file access, scope it to the relevant directories. Instead of blocking command execution, whitelist the commands that matter. A well-scoped agent is both safe and capable.

=== Tier 2: Direct Context Injection

Tools can't provide everything. Your mental model of why something was designed a certain way, constraints that were never written down, tribal knowledge about how the team works, domain expertise about the business — this is what _you_ bring. This is where copy-paste and direct instruction still matter.

*Start with the error — or let the agent find it.* If your agent has access to your error tracking system via MCP, let it pull the Sentry trace or Datadog alert itself. If it doesn't, paste the stack trace, the failing test output, the log line. Raw context beats paraphrased context every time — but the best version is the agent accessing the raw source directly.

*Give intent, not just implementation details.* A tool-equipped agent is surprisingly good at finding the right files. What it _can't_ find is your intent. "We need to fix the encoding bug in the billing pipeline, and the fix must not change the stored format because three downstream services depend on it" is the kind of context no tool can discover. Focus your manual input on the _why_ and the _constraints_, not the _where_.

*Raw data over paraphrase — and ideally, let the agent access the source.* This is the most common mistake I see: engineers describing an error in their own words instead of providing the actual error. "The build is failing with some TypeScript error about types" versus the exact compiler output with file path, line number, and error code. The first gives the agent a vague direction. The second gives it a specific target. But the best version is an agent that can run the build itself and see the error firsthand.

*Use git blame to explain _why_ — or let the agent run it.* Code tells the agent _what_ exists. Git history tells it _why_. When you're asking an agent to modify code that has a non-obvious design, the relevant commit message or pull request gives it the rationale it needs. If your agent can run `git blame` and `git log` itself, it can find this history. What it still needs from you is the _interpretation_: "This function looks weird but it was written this way because of a payment gateway quirk that isn't documented anywhere — see `abc123`."

*Prune aggressively — by scoping tools.* If you're debugging a rendering issue, the agent doesn't need to see your authentication middleware. With manual context, this means being selective about what you paste. With tool-equipped agents, it means scoping file access or working in a focused worktree. Every irrelevant file in context is noise that degrades the signal, whether it got there by paste or by tool.

*Layer your context.* For complex tasks, don't dump everything at once. Start with the high-level picture — what the system does, what you're trying to change, why. Then provide the specific files. Then provide the error or test failure. This mirrors how you'd brief a human colleague, and it works for the same reason: it builds a mental model before diving into specifics.

*Equip, don't spoon-feed.* When you catch yourself about to paste a file into the context window, ask: could the agent have found this on its own if it had the right tools? If yes, invest the time in setting up that access instead. Pasting is a one-time fix. Tooling is a permanent upgrade. The goal is an agent that needs you for your judgment, not your clipboard.

== Context Across Sessions

Here's a problem nobody warns you about: context windows are ephemeral. When a session ends, everything the agent learned — every file it read, every decision it made, every dead end it explored — vanishes. The next session starts from zero.

For short tasks, this doesn't matter. You paste in the error, the agent fixes it, done. But real engineering work spans days, sometimes weeks. A feature that touches twelve files across three services. A refactoring that needs to happen in stages. A debugging session where the first two hours narrow down the problem and the last thirty minutes fix it — except you had to close your laptop in between.

If you don't plan for session boundaries, you'll waste enormous amounts of time re-establishing context that the agent already had. I've watched engineers spend the first fifteen minutes of every session re-explaining what they told the agent yesterday. That's not engineering. That's babysitting.

The solution is to make context _durable_ — to store it somewhere the next session can pick it up.

*Let the codebase be the continuity layer.* The most reliable form of cross-session context is the code itself. If the agent made progress yesterday, that progress should be committed. Good commit messages become the breadcrumb trail: "Refactored payment gateway to separate encoding step — next step is to add tests for non-ASCII input." The next session starts by reading the recent git log, and the agent has a clear picture of where things stand.

*Use CLAUDE.md files (or their equivalent).* Many agent tools support a project-level context file — a markdown file at the root of your repo that describes the project's architecture, conventions, and current state. This file persists across sessions because it lives in the filesystem. Update it as the project evolves. Include things like: what the major components are, what patterns to follow, what's currently broken, what the team is working on. It's a briefing document that every new session reads automatically.

*Write session summaries.* When you finish a complex session, spend sixty seconds having the agent summarise what it accomplished, what's left to do, and what it learned about the codebase. Save that summary somewhere — a comment on the ticket, a note in the project, even a text file in the repo. The next session starts by reading that summary, and you've preserved hours of accumulated understanding in a few paragraphs.

*Commit early and often.* This is covered in the Git chapter, but it bears repeating here because it's fundamentally a context management strategy. Every commit is a checkpoint that future sessions can reference. A session that ends with uncommitted changes is a session whose context is trapped in a terminal window that might not exist tomorrow.

The engineers who handle long-running agentic work well are the ones who treat session boundaries as a first-class concern. They don't just close the laptop — they close the loop.

== Context as Architecture

Here's the deeper insight: as you get better at agentic engineering, you start designing your systems _for_ context. You write clearer commit messages because agents read them. You keep functions small because agents work better with focused files. You maintain up-to-date docs because agents treat them as ground truth.

This isn't a minor adjustment. It changes how you think about code structure at every level.

*Small functions are context-friendly.* A 400-line function requires the agent to hold the entire thing in working memory to make a change safely. A 30-line function that does one thing is something the agent can understand completely, modify confidently, and verify quickly. The old advice — "a function should do one thing" — was always good engineering. Now it's good context management too. Every time you extract a well-named function from a larger one, you're creating a unit of meaning that an agent can work with independently.

*File naming is navigation.* When an agent needs to find the code that handles user authentication, it starts by looking at file names. `auth.ts` is a signal. `utils.ts` is a black hole. `handleStuff.js` is a dead end. The discipline of naming files clearly — `user-authentication.ts`, `payment-gateway.ts`, `rate-limiter.middleware.ts` — is no longer just a courtesy to future developers. It's an index that agents use to find their way through your codebase without reading every file.

*Directory structure is architecture documentation.* A flat directory with sixty files tells the agent nothing about how the system is organised. A clear hierarchy — `src/api/`, `src/services/`, `src/models/`, `src/middleware/` — tells it everything. The agent can infer the architecture from the folder structure alone, without reading a single line of documentation. I've seen agents navigate a well-structured monorepo of 10,000 files more effectively than a poorly-structured project of 200, purely because the directory layout made the system legible.

*Monorepos vs. multirepos: a context tradeoff.* In a monorepo, the agent can see everything — the API, the frontend, the shared libraries, the infrastructure config. This is powerful for tasks that cross boundaries. But it also means the agent might see _too much_, pulling in irrelevant code from unrelated services. In a multirepo setup, each repo is naturally scoped — the agent sees only the service it's working on. But cross-service tasks become harder because the agent can't easily reference the other side of an API contract. Neither approach is universally better. The point is that your repo strategy is a context decision, whether you think of it that way or not.

*Types are context.* A strongly typed codebase gives an agent something that a dynamically typed one doesn't: a machine-readable description of every function's contract. The agent can look at a function signature and know exactly what goes in and what comes out, without reading the implementation. TypeScript, Rust, Go — these languages carry structural context in their type systems. Python and JavaScript leave the agent guessing unless you've written thorough docstrings or type hints. This isn't an argument for one language over another. It's an observation that type systems do double duty in the agentic era: they catch bugs _and_ they communicate intent.

*Documentation is ground truth (whether it's accurate or not).* Agents treat your README, your API docs, your inline comments as authoritative. If your docs say the API returns a `user_id` field but the actual response returns `userId`, the agent will write code against the documentation and produce a bug. Stale documentation was always a nuisance. With agents, it's an active source of defects. The bar for documentation accuracy goes up — not because agents need better docs than humans, but because agents will follow bad docs more faithfully than a human would.

The way you structure your code, your repos, your infrastructure — it all becomes part of the context you're providing to your crew. The engineers who understand this early will build systems that are not just maintainable by humans, but _navigable_ by agents. And over time, that navigability compounds — each new agent session benefits from every structural decision you made before it.
