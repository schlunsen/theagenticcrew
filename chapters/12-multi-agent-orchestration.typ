= Multi-Agent Orchestration

#figure(
  image("../assets/illustrations/ch12-orchestration.jpg", width: 80%),
)

One agent is powerful. Multiple agents working together is something else entirely.

Think of it this way. A single carpenter can build a shed. But a house? You need an electrician, a plumber, a roofer — specialists working in parallel, each focused on what they do best, coordinating just enough to stay out of each other's way. The house goes up faster and the work is better than one person trying to do everything.

Agentic engineering works the same way. A single agent on a complex task will grind through it sequentially — plan, implement, test, debug, iterate. It works, but it's slow. Three agents, each handling a well-scoped piece of the problem, can finish in a third of the time. Sometimes less, because focused agents make fewer mistakes than one agent juggling too many concerns.

But there's a catch. Parallel agents require _coordination_. And coordination has a cost. This chapter is about when to pay that cost, and how to pay it well.

== Decomposition Strategies

The hardest part of multi-agent work isn't running multiple agents. It's deciding how to split the work.

The golden rule: tasks must have _minimal coupling_. If agent A's work depends on agent B's output, they can't run in parallel — they're sequential, and you should treat them that way. The art is finding seams in your work where you can cut cleanly.

There are three reliable decomposition patterns.

*By layer.* One agent handles the backend API, another builds the frontend component, a third writes the tests. This works well because layers have natural boundaries — a defined interface between them. As long as you agree on the API contract up front, each agent can work independently.

*By feature.* If you're building three independent features, give each to a separate agent. This is the simplest decomposition. The features touch different files, different directories, different concerns. Merge conflicts are rare.

*By concern.* One agent refactors, another writes tests for the refactored code, a third updates the documentation. This is a sequential pattern — more pipeline than parallel — but it lets each agent focus on a single type of thinking. The refactoring agent doesn't have to context-switch into test-writing mode. It just refactors, and hands off.

The decomposition you choose depends on the shape of the work. But the principle is constant: _find the seams, cut along them, minimise the surface area where agents need to agree_.

== Branch-per-Agent

Every agent gets its own branch. We covered this in the Git chapter. In multi-agent work, it becomes absolutely essential.

But branches alone aren't enough. Two agents on different branches sharing the same working directory will fight over the filesystem — they'll overwrite each other's files, corrupt each other's builds, break each other's test runs. You need _worktrees_.

Each agent gets its own git worktree: a separate directory, on its own branch, with its own copy of the codebase. The agents share history but nothing else. They can build, run tests, install dependencies, and make a mess — all without affecting each other.

The setup is quick:

```bash
git worktree add ../project-api agent/api-endpoint
git worktree add ../project-frontend agent/frontend-component
git worktree add ../project-tests agent/integration-tests
```

Three directories. Three branches. Three agents. Full isolation. This is the sandbox model from earlier chapters made concrete for multi-agent work. When an agent finishes, you review its branch, merge if it's good, and remove the worktree. If the work is bad, you throw the whole thing away. Zero cost.

== The Handover Pattern

Not all multi-agent work is parallel. Sometimes agents work _sequentially_, each building on the last. Agent A plans. Agent B implements. Agent C reviews.

This is the handover pattern, and it's powerful — but only if the handover itself is clean.

The problem with sequential agents is context loss. Agent A has a rich understanding of the problem by the time it finishes planning. Agent B starts cold. If you just tell Agent B "implement the plan," it's going to miss nuance. It'll make different assumptions. It'll solve a slightly different problem than the one Agent A planned for.

The fix is _structured handover_. Agent A doesn't just plan — it produces an artefact that captures its reasoning. This can take several forms:

- *A summary document.* A markdown file dropped into the repo: `PLAN.md`. It describes what needs to happen, what trade-offs were considered, what was rejected and why. Agent B reads this before writing a line of code.
- *A set of files.* Agent A creates stub files — empty functions with docstrings, interface definitions, type signatures. Agent B fills them in. The stubs _are_ the handover.
- *A structured prompt.* Agent A's output becomes Agent B's input, formatted as a detailed task description with acceptance criteria. You paste it directly into Agent B's context.

The key is that the handover must be _explicit and complete_. No implicit assumptions. No "the next agent will figure it out." Every decision, every constraint, every edge case — written down.

This takes discipline. But it's the same discipline you'd apply when writing a ticket for a human colleague on a different continent and a different timezone. If you wouldn't trust a verbal handover, don't trust an implicit one between agents.

== The Merge Problem

This is where multi-agent work gets genuinely hard.

Three agents worked in parallel. Each produced a clean, tested branch. Now you need to merge them all into main. Sometimes this is painless — three branches touching completely different files merge without a single conflict. Beautiful.

Sometimes it's not. Agent A changed the database schema. Agent B added a migration that assumes the old schema. Agent C updated the API handler that both A and B also touched. Now you have a three-way conflict and no single agent has the full picture.

There are three strategies for dealing with this.

*Prevention.* The best merge conflicts are the ones that never happen. When you decompose work, think about file ownership. Assign different directories, different modules, different files to different agents. If agents never touch the same file, they can never conflict. This is the cheapest strategy and you should use it whenever possible.

*The merge agent.* When conflicts do arise, spin up a new agent whose sole job is to merge. Give it the branches, the conflicts, and the context from each agent's work. A good merge agent can resolve most conflicts automatically — it reads both sides, understands the intent, and produces a coherent result. It's like a senior engineer who sits down with two PRs and figures out how they fit together.

*Human review.* Sometimes the conflict is semantic, not syntactic. The code merges cleanly but the _logic_ contradicts itself. Two agents made incompatible design decisions. No automated merge will catch this. This is where you earn your keep as the engineer. Review the branches before merging. Read the diffs side by side. Make sure the pieces actually fit.

In practice, you'll use all three. Prevent what you can. Automate the rest. Review everything.

== The Visibility Problem

There is a practical challenge that hits the moment you move from one agent to three: you lose track of what's happening. Four terminal windows open, agents working on different tasks, one crashed silently twenty minutes ago and you haven't noticed. The agents are fine. _You_ are the bottleneck.

This is a tooling problem, not an intelligence problem. If your workflow does not give you visibility into parallel work, you will either serialise everything — wasting the agents' potential — or run things in parallel and lose track, wasting your own time cleaning up the mess. Whatever tool you use — tmux panes, multiple editor windows, a browser-based control plane like wee (#link("https://wee.cat")), or even a sticky note tracking what is running where — solve the visibility problem first. The agents will not manage themselves.

#figure(
  image("../assets/wee-dashboard.png", width: 100%),
  caption: [A multi-session dashboard — multiple agent sessions running in parallel, with real-time status and cost tracking.],
)

#figure(
  image("../assets/wee-new-session.png", width: 80%),
  caption: [Creating a new session with worktree isolation, permission mode, and model selection — every principle from this book baked into a single dialog.],
)

== Orchestration Overhead

More agents is not always better.

Every additional agent adds coordination cost. You have to decompose the work. Set up worktrees. Define interfaces. Handle merges. Review multiple branches instead of one. For a task that takes a single agent thirty minutes, spinning up three agents might take forty-five — twenty minutes of parallel agent work plus twenty-five minutes of your time orchestrating.

The break-even point is higher than you think. In my experience, multi-agent orchestration starts paying off when the total task would take a single agent _at least two hours_. Below that, the overhead eats the gains.

There are other costs too. Context gets fragmented. Each agent sees only its piece. No single agent understands the whole system the way one agent working alone would. This can lead to inconsistencies — different naming conventions, different error handling patterns, different assumptions about shared state.

The skill isn't running as many agents as possible. The skill is knowing _when_ to parallelise and when a single focused agent is the right tool. A crew of five isn't always faster than one experienced sailor who knows the boat.

== A Practical Example

Let's make this concrete. You're building a web app and you need to add a new feature: user notifications. Users should see a bell icon with a count, click it to see a list, and mark notifications as read. You need an API, a frontend component, and tests.

This is a textbook case for three parallel agents.

*Step 1: Define the interface.* Before spinning up any agents, you spend five minutes writing down the API contract. `GET /api/notifications` returns a list. `PATCH /api/notifications/:id` marks one as read. The notification object has `id`, `message`, `read`, `created_at`. Write this in a shared document or a stub file. This is the contract all three agents work against.

*Step 2: Create the worktrees.*

```bash
git worktree add ../app-api agent/notifications-api
git worktree add ../app-frontend agent/notifications-frontend
git worktree add ../app-tests agent/notifications-tests
```

*Step 3: Launch the agents.* Each agent gets a clear, scoped task:

- Agent 1: "Implement the notifications API endpoints in `../app-api`. Follow the contract in `API_CONTRACT.md`. Include model, route, and controller. Write unit tests for the controller."
- Agent 2: "Build the notifications UI component in `../app-frontend`. It calls `GET /api/notifications` and `PATCH /api/notifications/:id`. Show a bell icon with unread count. Clicking opens a dropdown list."
- Agent 3: "Write integration tests in `../app-tests`. Cover the full flow: create a notification, fetch the list, mark as read, verify the count updates."

*Step 4: Let them work.* The three agents run simultaneously. Each commits to its own branch. You monitor progress but don't intervene unless something goes wrong.

*Step 5: Review and merge.* When all three finish, you review each branch. The API branch gets merged first — it's the foundation. Then the frontend branch. Then the tests. You run the full test suite after each merge to catch integration issues early.

Total time: maybe forty minutes. The API agent took thirty, the frontend agent took twenty-five, and the test agent took thirty-five. But they ran in parallel, so wall-clock time was thirty-five minutes plus ten minutes of your orchestration work.

A single agent doing everything sequentially? Probably ninety minutes.

The maths works when the task is big enough. And as you get better at decomposition, you'll develop an intuition for which tasks are worth splitting and which aren't. Like most things in engineering, it's a judgement call. But now you have the tools to make it.

One more thing worth noting: you don't always have to orchestrate manually. As we discussed in the prompting chapter, you can _tell_ the agent to parallelise. "These three modules are independent — launch sub-agents and work on them simultaneously." The agent handles the worktrees, the branching, and the coordination. Your job is the part the agent can't do: knowing which pieces are safe to run in parallel. That architectural judgement is the highest-leverage prompt you can write.
