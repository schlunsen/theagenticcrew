= What I Learned Building My Own Agentic Tooling

Before we get into the principles, let me tell you about the thing that taught me most of them. I spent a hundred hours building my own agentic IDE — and in the process, I discovered what agentic engineering actually _is_. The lessons were expensive, occasionally embarrassing, and worth every minute.

== The Problem Nobody Warns You About

Here is what nobody tells you when you start working with AI agents: the hard part is not getting one agent to do something useful. The hard part is managing the chaos when you have three of them running at once.

I hit this wall about two months into agentic engineering. I had four terminal windows open. One agent was refactoring an API layer. Another was writing tests. A third was updating documentation. The fourth had crashed silently twenty minutes ago and I hadn't noticed. I was switching between tabs, losing track of which agent was where, mentally juggling four different contexts, and doing it badly.

The agents were fine. _I_ was the bottleneck. I didn't have a management problem — I had a visibility problem.

So I did what any engineer with too much free time would do: I spent a hundred hours building my own tool. Clovr Code Terminal — CCT — a browser-based control plane for running multiple agent sessions. Was it the most efficient use of my time? Probably not. But those hundred hours taught me more about agentic engineering than any amount of reading could have.

This chapter is about those lessons. CCT is the case study, not the point. Everything I learned applies regardless of what tools you use.

== The Insight: Agentic Work Is Inherently Parallel

The first thing building CCT forced me to confront is that single-agent workflows are a crutch. Not always — sometimes one agent on one task is exactly right. But the real power of agentic engineering shows up when you run multiple agents in parallel, each focused on a different piece of the problem.

This is counterintuitive. Most of us came up through a world where _we_ are the single thread of execution. We write code, then we write tests, then we update docs. Sequential. One thing at a time. Agents break that model. They can all work simultaneously — but only if you can keep track of them.

In CCT, this looks like a sidebar showing all active sessions: which files each agent is reading, which commands it is running, how many tokens it has consumed. But the principle is bigger than any sidebar. If your agentic workflow does not give you visibility into parallel work, you will either serialize everything (wasting the agents' potential) or run things in parallel and lose track (wasting your own time cleaning up the mess).

#figure(
  image("../assets/cct-dashboard.png", width: 100%),
  caption: [CCT's main dashboard — multiple agent sessions running in parallel, with real-time status and cost tracking. The sidebar is a management tool, not a feature.],
)

Whatever tool you use — Claude Code in tmux panes, Cursor with multiple projects, even just a notebook where you track what is running where — solve the visibility problem first. The agents will not manage themselves.

== The Insight: Agents Need Structured Context Passing

The feature I am proudest of in CCT is session handovers, but the _lesson_ behind it matters more than the implementation.

Here is the problem: you have an agent that just finished planning a feature. It knows the requirements, the file structure, the edge cases. Now you want a different agent — maybe a specialist, maybe just a fresh context window — to implement what was planned. How do you transfer that knowledge?

The naive approach is copy-paste. Grab the plan from agent one's output, paste it into agent two's prompt. This works, barely. You lose nuance. You forget things. You become a human clipboard, which is exactly the kind of low-value work agents are supposed to eliminate.

The better approach is structured handovers: a defined format for passing context from one agent to another. In CCT, this is a time-limited, single-use token carrying a summary of what was done, which files changed, and what remains. But you do not need CCT to do this. You need the _discipline_ of structured handovers.

Write a handover template. Make agents summarize their work in a consistent format before they finish. Feed that summary to the next agent. This is the "crew" metaphor made operational — agents collaborating not through shared memory, but through structured communication.

I have used this pattern to chain three agents in sequence: one to plan, one to design, one to implement. Each reads the previous agent's handover. The result is consistently better than a single agent trying to do everything, because each agent works within a focused context instead of a sprawling one.

== The Insight: Trust Must Be Configurable

Every tool call an agent makes — every bash command, every file write, every network request — is a trust decision. Early on, I ran agents with no guardrails at all. Full filesystem access, unrestricted command execution, the works. It was fast and it was terrifying. One agent ran `rm -rf` on a directory I cared about. (It was in a worktree, so no real damage. Lesson learned anyway.)

The opposite extreme — approving every single operation manually — makes agents useless. You spend all your time clicking "allow" on `git status` and `ls` commands. The agent's throughput drops to whatever speed you can review permission requests.

The real answer is a configurable trust spectrum. In CCT, this means always-allow rules for safe commands (`git status`, `npm test`, `ls`), manual approval for sensitive operations, and a full-auto mode for rapid prototyping in disposable environments. Over time, your permission config becomes a living document of your trust relationship with the agents.

But here is the universal principle: _any_ agentic workflow needs a way to tune trust. If your tool only offers "allow everything" or "approve everything," you will oscillate between anxiety and frustration. Look for the middle ground. Build it if you have to. The permission layer is not overhead — it is what makes sustained agentic work possible.

== The Insight: Version Control IS Agent Infrastructure

I did not set out to make CCT git-aware. It happened because every time an agent made a mess, my first instinct was `git diff` and `git stash`. Version control was already my safety net. Making it first-class in the tool just formalized what I was doing manually.

Every session in CCT knows its git context. You can view diffs, compare against main, and track which session modified which files. When you create a new session, CCT can spin up a git worktree automatically — giving the agent its own isolated copy of the repo, its own branch, its own room to experiment.

This principle applies everywhere: _never let an agent work on your main branch_. Give it a branch. Give it a worktree. Give it a container. Whatever isolation mechanism you prefer, use it. Good results get merged. Bad results get deleted. No mess, no risk, no drama.

#figure(
  image("../assets/cct-new-session.png", width: 80%),
  caption: [Creating a new session with worktree isolation, permission mode, and model selection — every principle from this book baked into a single dialog.],
)

If you are using Claude Code in a terminal, a simple shell script that creates a worktree and starts a session gives you eighty percent of this benefit. The tooling does not matter. The isolation does.

== Staying Connected Without Staying Chained

A smaller lesson, but one that changed my daily workflow: agents do not need you watching them constantly. They need you _available_ when they have a question.

I built an iOS companion for CCT because I am often away from my desk — picking up the children, making dinner, pretending to be present at family events. The app shows me what agents are doing and lets me approve permission requests from my phone. But the principle is not "build a mobile app." The principle is: _design your workflow so agents can make progress without you, and interrupt you only when they genuinely need input._

This might mean running agents in a tmux session you check periodically. Or setting up notifications for when a session finishes or errors out. Or just accepting that an agent will block on a permission request for ten minutes while you finish lunch. The goal is asynchronous collaboration between you and your agents, not synchronous babysitting.

== You Do Not Need to Build Your Own

I want to be direct about this, because it is the most important section in the chapter: _do not build your own agentic IDE._ Probably. Almost certainly. I did it because I had specific itches to scratch and because the process of building it taught me things I wanted to write about. But I could have been productive with Claude Code in a terminal and a few good shell scripts. Many excellent engineers are.

The principles in this chapter — parallel visibility, structured handovers, configurable trust, version control as infrastructure — can be implemented with any tool:

- *Parallel visibility:* tmux panes, a simple log file, even a sticky note tracking what is running where.
- *Structured handovers:* a markdown template that agents fill out when they finish. Copy it to the next agent's prompt.
- *Configurable trust:* Claude Code's permission flags, `.claude/settings.json`, or just running agents in a restricted sandbox.
- *Git isolation:* a three-line shell script that creates a worktree and starts a session.

The tool does not matter. The mental model does. If you understand _why_ these patterns exist, you can implement them with whatever you have.

== What I Would Build Differently

A hundred hours is a lot of time. Not all of it was well spent. In the spirit of honesty:

*The multi-provider abstraction was overengineered.* I built support for swapping between Claude, DeepSeek, Kimi, and other providers per session. In practice, I use Claude for ninety-five percent of tasks. The abstraction layer added complexity to every feature I built afterward. If I started over, I would build for one provider and add others only when I actually needed them. YAGNI applies to tooling too.

*The permission system was too granular at first.* My initial design had per-directory, per-command, per-session permissions. Nobody — including me — wanted to configure that. I simplified it to three modes (manual, rules-based, auto-approve) and never looked back. Start simple. Add granularity only when you feel the pain of not having it.

*I underestimated the value of good defaults.* Early versions of CCT required configuration for everything. The version I actually use has strong defaults and only surfaces options when you need them. This mirrors a broader principle in agentic engineering: convention over configuration. (There is a whole chapter on that later.)

*I spent too long on the UI and not enough on the handover format.* The dashboard looks nice. The handover system — the part that actually makes multi-agent workflows possible — went through four rewrites before I got it right. If I started over, I would nail the handover protocol first and worry about the dashboard later. The boring infrastructure always matters more than the shiny interface.

These are not regrets. Each mistake taught me something about what matters in agentic tooling. But if you are building your own tools — even small scripts and wrappers — learn from my overengineering. Start with the minimum that solves your actual problem. Expand when reality demands it, not when your imagination suggests it.

== The Real Lesson

Building CCT taught me that agentic engineering is not really about the agents. It is about the _systems around the agents_ — the visibility, the context passing, the trust boundaries, the isolation, the feedback loops. Get those right and almost any capable model will produce good results. Get them wrong and even the best model will create expensive chaos.

The rest of this book is about those systems. The principles I stumbled into while building a tool, extracted and generalized so you can apply them without spending a hundred hours on your own IDE.

You are welcome for the shortcut.
