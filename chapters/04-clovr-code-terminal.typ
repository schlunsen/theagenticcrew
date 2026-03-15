= Building My Own IDE: Clovr Code Terminal

Before we get into the principles, let me tell you about the thing that taught me most of them.

I spent over a hundred hours building Clovr Code Terminal — CCT — my own IDE for agentic engineering. A hundred hours of watching agents write code, break things, fix things, and surprise me. A hundred hours of learning what works, what doesn't, and why. Every chapter that follows in this book grew out of lessons I learned building this tool.

CCT started from a simple frustration: I was running multiple Claude Code sessions in separate terminal windows, constantly switching between them, losing track of which agent was doing what. I wanted a mission control. So I built one — and in the process, I discovered what agentic engineering actually is.

== What CCT Is

CCT is a self-hosted control plane for agentic engineering. It's a single 15MB Go binary that gives you a browser-based dashboard for running, monitoring, and orchestrating multiple AI agent sessions simultaneously. It can run on your local machine or on a server somewhere — a sandbox you SSH into, a VPS, a beefy cloud instance. The agent sessions run where CCT runs, and you control them from any browser.

You start it with one command. No dependencies, no npm install, no Docker required. Just a binary and a browser.

The core idea: you're the engineer, the agents are your crew, and CCT is the bridge where you coordinate them.

#figure(
  image("../assets/cct-dashboard.png", width: 100%),
  caption: [CCT's main dashboard — multiple agent sessions running in parallel, with real-time cost tracking, model selection, and session metadata in the sidebar.],
)

== Multiple Sessions, One View

The sidebar shows all your active sessions. Each one is a separate Claude agent with its own working directory, its own git branch, its own conversation history. You can see at a glance what each agent is doing — which files it's reading, which commands it's running, how many tokens it's consumed, what it's costing you.

This changes how you work. Instead of giving one agent a big task and waiting, you break the work into parallel tracks. One agent refactors the API layer. Another writes tests for the new feature. A third updates the documentation. You glance at the sidebar, check their progress, intervene when needed, and let them run when they're on track.

The sessions persist across restarts. Come back the next morning and your agents' full conversation history is there in SQLite, ready to continue.

== Session Handovers

One of the features I'm most proud of is session handovers. When one agent finishes a task, it can hand its context — a summary of what it did, which files it changed, what's left to do — to a new agent session. The handover is a structured token: time-limited, single-use, carrying just enough context for the next agent to pick up where the last one left off.

This enables pipeline-style workflows. I built a site generator inside CCT that uses three specialist agents in sequence: an orchestrator that plans the work, a designer that creates the visual structure, and an implementer that writes the code. Each one hands off to the next. The result is better than any single agent could produce, because each specialist focuses on what it does best.

The handover system is the "crew" metaphor made concrete. Agents don't work alone — they collaborate through structured context passing.

== The Permission Layer

Every tool call an agent makes — every bash command, every file write, every network request — goes through CCT's permission system. You can set it to approve everything automatically (YOLO mode, useful during rapid prototyping), or require explicit approval for sensitive operations.

There's also a middle ground: always-allow rules. You can whitelist specific commands (`git status`, `npm test`, `ls`) while requiring approval for everything else. Over time, your permission config becomes a reflection of your trust relationship with the agents — how much rope you give them, and where you pull them back.

This is the guardrails chapter in practice.

== Providers and Models

CCT isn't locked to one AI provider. You can configure Claude, DeepSeek, Kimi, GLM, or any Anthropic-compatible endpoint — and switch between them per session, without restarting. Running a quick documentation task? Point it at a cheaper model. Doing complex multi-file refactoring? Switch to Opus.

This is the local-vs-commercial chapter in practice. The tool doesn't have opinions about which model you use. It gives you the controls to make that choice per task.

== Git-Aware by Default

Every session knows its git context. The sidebar shows the current branch. You can view diffs, compare against main, and track which session modified which files. When you create a new session, CCT can spin up a git worktree automatically — giving the agent its own isolated copy of the repo.

This is the sandboxes chapter in practice. Each agent gets its own workspace, its own branch, its own room to experiment. Good results get merged. Bad results get deleted with the worktree. No mess.

#figure(
  image("../assets/cct-new-session.png", width: 80%),
  caption: [Creating a new session — you pick the working directory, enable worktree isolation, set the permission mode, and choose your model provider. Every principle from this book in one dialog.],
)

== Running Anywhere

CCT is a single binary. This means it runs wherever you need it:

*On your laptop* — the simplest setup. The agents work in your local projects, with access to your filesystem and tools. Good for daily development.

*On a remote server* — SSH in, start CCT, point your browser at it. The agents run on server hardware (maybe beefier than your laptop), and you get a clean sandbox environment. Good for heavy workloads or when you want isolation from your local machine.

*In a container* — spin up a Docker instance with CCT and your project, give it scoped credentials, let the agents go wild. Destroy it when you're done. Good for CI-style agent work or security-sensitive tasks.

The architecture is intentionally simple: one binary, one SQLite database, one WebSocket connection to your browser. No microservices, no message queues, no distributed systems. It's a tool, not a platform.

== The iOS Companion

Because I'm often away from my desk — picking up the children, making dinner, pretending to be present — I built an iOS app that connects to CCT. It shows me what my agents are doing in real time. If an agent hits a permission request, I can approve it from my phone. If a session finishes, I see the result.

This is a small thing, but it changed my workflow significantly. Agents don't need me watching them constantly. They need me available when they have a question. The mobile app makes that possible without being chained to a screen.

== Why I Built It

I could have used Claude Code in the terminal and been fine. Many excellent engineers do exactly that. But I wanted something that made the _multi-agent workflow_ first-class. I wanted to see all my agents at once. I wanted structured handovers. I wanted permission controls I could tune. I wanted it running on a server I could access from anywhere.

More than anything, building CCT taught me what agentic engineering actually _feels_ like at the infrastructure level. Every feature I added — sessions, handovers, permissions, worktree isolation — forced me to think deeply about the principles in this book. Context management, guardrails, sandboxing, testing — they're not abstract ideas when you're implementing them in code.

The tool is a reflection of the practice. And the practice made me a better engineer.

== You Don't Need to Build Your Own

Let me be clear: you don't need to build a custom IDE to be a great agentic engineer. Claude Code in a terminal is powerful enough for most workflows. Cursor, Windsurf, and other tools are excellent.

What you _do_ need is to understand the principles well enough that you can shape your tools to fit your workflow — not the other way around. Whether that means writing custom `CLAUDE.md` files, configuring permission rules, setting up worktree scripts, or building an entire control terminal from scratch.

The best tool is the one that gets out of your way and lets you focus on the engineering. For me, that's CCT. For you, it might be something else entirely. The principles are the same.
