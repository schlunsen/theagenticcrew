= Context

The single most important skill in agentic engineering isn't prompting. It's context management.

An AI agent is only as good as what it can see. Give it a vague instruction and a blank slate, and it will hallucinate confidently. Give it the right files, the right constraints, the right view of the system — and it will do things that feel like magic. The difference isn't the model. It's you.

Traditional engineering had a version of this too. A senior engineer didn't just write better code — they held more of the system in their head. They knew which files mattered, where the dragons lived, which abstractions were load-bearing and which were decorative. That mental model was the context, and it lived entirely in the engineer's brain.

Now you have to _externalise_ it. Your agents can't read your mind. They read files, environment variables, error logs, and whatever you put in front of them. The craft of agentic engineering is learning what to surface, when, and how.

== The Context Window Is Your Workbench

Think of the context window as a physical workbench. It has limited space. You can't dump your entire codebase on it and expect good results. Instead, you lay out the pieces that matter for _this_ task: the relevant source files, the failing test, the schema, maybe a snippet of documentation.

A good agentic engineer curates context the way a good surgeon lays out instruments. Nothing unnecessary. Everything within reach.

This means developing instincts for questions like:
- What does the agent need to see to understand this task?
- What will confuse it if I include it?
- Is the context I'm providing _current_, or am I feeding it stale information?

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

The best agentic engineers develop habits around context:

*Start with the error.* Don't describe the bug — show the agent the stack trace, the failing test output, the log line. Raw context beats paraphrased context every time.

*Show, don't tell.* Instead of explaining your database schema in prose, give the agent the migration files or the ORM models. Instead of describing the API contract, give it the OpenAPI spec or a curl response.

*Prune aggressively.* If you're debugging a rendering issue, the agent doesn't need to see your authentication middleware. Every irrelevant file in context is noise that degrades the signal.

*Use the filesystem as context.* A well-organised project _is_ context. Meaningful file names, clear directory structure, a good README — these aren't just for humans anymore. Your agents read them too.

== Context as Architecture

Here's the deeper insight: as you get better at agentic engineering, you start designing your systems _for_ context. You write clearer commit messages because agents read them. You keep functions small because agents work better with focused files. You maintain up-to-date docs because agents treat them as ground truth.

The way you structure your code, your repos, your infrastructure — it all becomes part of the context you're providing to your crew. The engineers who understand this early will build systems that are not just maintainable by humans, but _navigable_ by agents.

And that's a competitive advantage that compounds over time.
