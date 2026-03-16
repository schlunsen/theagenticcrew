= What I Learned Building My Own Agentic Tooling

Here is what nobody tells you when you start working with AI agents: the hard part is not getting one agent to do something useful. The hard part is managing the chaos when you have three of them running at once. Four terminal windows open, agents working on different tasks, one crashed silently twenty minutes ago and you haven't noticed. The agents are fine. _You_ are the bottleneck.

I spent a hundred hours building my own tool to solve this — Clovr Code Terminal, a browser-based control plane for running multiple agent sessions. Those hours taught me more about agentic engineering than any amount of reading could have. This chapter distils the principles that emerged. CCT is the case study, not the point.

== Agentic Work Is Inherently Parallel

Single-agent workflows are a crutch. Not always — sometimes one agent on one task is exactly right. But the real power of agentic engineering shows up when you run multiple agents in parallel, each focused on a different piece of the problem.

This is counterintuitive. Most of us came up through a world where _we_ are the single thread of execution. Write code, then tests, then docs. Sequential. Agents break that model — they can all work simultaneously, but only if you can keep track of them.

If your workflow does not give you visibility into parallel work, you will either serialise everything (wasting the agents' potential) or run things in parallel and lose track (wasting your own time cleaning up the mess). Whatever tool you use — tmux panes, multiple Cursor projects, even a sticky note tracking what is running where — solve the visibility problem first. The agents will not manage themselves.

#figure(
  image("../assets/cct-dashboard.png", width: 100%),
  caption: [CCT's main dashboard — multiple agent sessions running in parallel, with real-time status and cost tracking.],
)

== Agents Need Structured Context Passing

You have an agent that just finished planning a feature. It knows the requirements, the file structure, the edge cases. Now you want a different agent to implement what was planned. How do you transfer that knowledge?

The naive approach is copy-paste — grab the plan from agent one's output, paste it into agent two's prompt. This works, barely. You lose nuance, forget things, and become a human clipboard, which is exactly the kind of low-value work agents are supposed to eliminate.

The better approach is structured handovers: a defined format for passing context from one agent to another. Write a handover template. Make agents summarise their work in a consistent format before they finish. Feed that summary to the next agent. This is the "crew" metaphor made operational — agents collaborating not through shared memory, but through structured communication.

I have used this pattern to chain three agents in sequence: one to plan, one to design, one to implement. Each reads the previous agent's handover. The result is consistently better than a single agent trying to do everything, because each agent works within a focused context instead of a sprawling one.

== Trust Must Be Configurable

Every tool call an agent makes — every bash command, every file write, every network request — is a trust decision. Running agents with no guardrails is fast and terrifying. One of mine ran `rm -rf` on a directory I cared about. (It was in a worktree, so no real damage. Lesson learned anyway.) The opposite extreme — approving every single operation manually — makes agents useless. You spend all your time clicking "allow" on `git status` and `ls`.

The real answer is a configurable trust spectrum. Always-allow rules for safe commands, manual approval for sensitive operations, and full-auto mode for rapid prototyping in disposable environments. Over time, your permission config becomes a living document of your trust relationship with the agents.

Any agentic workflow needs a way to tune trust. If your tool only offers "allow everything" or "approve everything," you will oscillate between anxiety and frustration. The permission layer is not overhead — it is what makes sustained agentic work possible.

== Version Control Is Agent Infrastructure

Every time an agent made a mess, my first instinct was `git diff` and `git stash`. Version control was already my safety net. Making it first-class in the tooling just formalised what I was doing manually.

The principle is simple: _never let an agent work on your main branch_. Give it a branch. Give it a worktree. Give it a container. Whatever isolation mechanism you prefer, use it. Good results get merged. Bad results get deleted. No mess, no risk, no drama.

#figure(
  image("../assets/cct-new-session.png", width: 80%),
  caption: [Creating a new session with worktree isolation, permission mode, and model selection — every principle from this book baked into a single dialog.],
)

If you are using Claude Code in a terminal, a simple shell script that creates a worktree and starts a session gives you eighty percent of this benefit. The tooling does not matter. The isolation does.

== You Do Not Need to Build Your Own

I want to be direct: _do not build your own agentic IDE._ I did it because I had specific itches to scratch and because building it taught me things I wanted to write about. But I could have been productive with Claude Code in a terminal and a few good shell scripts.

The principles in this chapter — parallel visibility, structured handovers, configurable trust, version control as infrastructure — can be implemented with any tool:

- *Parallel visibility:* tmux panes, a simple log file, even a sticky note tracking what is running where.
- *Structured handovers:* a markdown template that agents fill out when they finish. Copy it to the next agent's prompt.
- *Configurable trust:* Claude Code's permission flags, `.claude/settings.json`, or just running agents in a restricted sandbox.
- *Git isolation:* a three-line shell script that creates a worktree and starts a session.

The tool does not matter. The mental model does.

== The Real Lesson

Agentic engineering is not really about the agents. It is about the _systems around the agents_ — the visibility, the context passing, the trust boundaries, the isolation, the feedback loops. Get those right and almost any capable model will produce good results. Get them wrong and even the best model will create expensive chaos.

The rest of this book is about those systems.
