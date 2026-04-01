= Agentic Teams

#figure(
  image("../assets/illustrations/ch16-crew.jpg", width: 80%),
)

Software has always been a team sport. Agents don't change that. But they change the shape of the team, the rhythm of the work, and the skills that matter. If you're leading a team — or working on one — you need to think about this now, not later.

== The 10x Multiplier Is Real, but Distributed Differently

You've heard the claim: agents make engineers 10x more productive. It's not wrong. It's just misleading.

Agents make certain tasks _dramatically_ faster. Generating boilerplate, writing test scaffolding, refactoring across a hundred files, migrating API versions, wiring up CRUD endpoints — these go from hours to minutes. The speed gain is real and it's massive.

But other tasks barely change. System design still requires thinking. Debugging a subtle race condition still requires patience, intuition, and deep understanding of the runtime. Stakeholder conversations still take however long they take. The agent can't sit in your architecture review and ask the right questions.

The 10x multiplier isn't a flat multiplier across your day. It's a spike graph. Some tasks go 50x faster. Some go 1x. A few might even slow down if you fight the agent instead of doing it yourself.

Teams that understand this deploy agents strategically. They don't hand every task to an agent and expect magic. They identify the high-leverage zones — the tasks where agents genuinely compress timelines — and they focus agent effort there. The rest stays human.

== Code Review Changes

Here's what happens when agents enter a team's workflow: PR volume goes up. _Way_ up. An engineer who used to open two PRs a day now opens five. The code in those PRs is syntactically correct, well-formatted, and passes tests. And reviewing it is _exhausting_.

The old model of code review — read every line, check for off-by-one errors, verify edge case handling — doesn't scale when half the code was generated in seconds. You'll burn out your reviewers in a week.

The shift is from "is this correct?" to "is this the right approach?" Agent-generated code is usually _locally_ correct. It does what was asked. The question is whether what was asked was the right thing. Does this new service need to exist, or should this logic live in the existing one? Is this the right abstraction boundary? Does this change make the system simpler or more complex?

Reviewers become architects. They zoom out. They check intent, not implementation.

Practical adaptations that work:
- Smaller, more focused PRs — easier for both agents and reviewers
- Automated checks handle the mechanical stuff (linting, test coverage, type checking)
- Review time is protected on the calendar, not squeezed between meetings
- Teams agree on "trusted patterns" — if a PR follows a known pattern and passes CI, it gets a faster review track

Review fatigue is the silent killer of agent-assisted teams. Take it seriously.

== The Junior Engineer Question

This is the hardest problem in this chapter, and I don't have a clean answer.

Junior engineers have traditionally learned by doing the work that agents now do faster and better. Writing that first CRUD endpoint. Wrestling with a tricky CSS layout. Figuring out why the test is failing. These tasks were tedious for seniors but _formative_ for juniors. The struggle was the education.

If agents handle all of that, where does the learning happen?

The worst outcome is juniors who become prompt-dependent — they can get an agent to generate code, but they can't explain what the code does or debug it when it breaks. They skip the understanding phase entirely. That's not engineering; that's a very expensive copy-paste workflow.

The better path is using agents as _tutors_, not replacements. A junior writing a database migration should ask the agent to _explain_ the migration, not just generate it. "Why did you use a transaction here?" "What happens if this fails halfway?" "Show me what this looks like without the ORM." The agent becomes a patient teacher with infinite time — something most seniors can't offer.

Pair programming with agents, _supervised by seniors_, is the most promising model I've seen. The junior drives the agent. The senior watches, asks questions, and intervenes when the junior accepts something they don't understand. It's slower than letting the agent do everything, but it produces engineers who actually know what they're doing.

Teams that skip this investment are borrowing from the future. Today's unsupervised juniors are tomorrow's seniors who can't debug production without an AI crutch.

== Knowledge Distribution

Here's a pattern that shows up in every team that adopts agents unevenly: one engineer gets fluent with agents, starts shipping at 3x the rate of everyone else, and within a few months has touched every part of the codebase. They become the single point of failure.

The bus factor drops to one. Not because anyone planned it, but because velocity and knowledge concentration are correlated. The engineer who ships the most learns the most. The others fall behind, not just in output but in _understanding_ of the system they collectively own.

This is a management problem, not a technology problem. The fix is structural:

- *Shared `CLAUDE.md` files.* Every project has one. Everyone contributes to it. It encodes the team's collective knowledge, not one person's.
- *Shared workflows and conventions.* The team agrees on how they use agents — which tools, which patterns, which guardrails. No lone-wolf setups.
- *Rotation.* Agent-fluent engineers rotate to different parts of the codebase. Knowledge spreads through work, not documentation.
- *Agent session sharing.* Some teams have started sharing interesting agent sessions — the prompts, the outputs, the decisions. It's a form of knowledge transfer that didn't exist before.

The goal isn't to slow down your fastest engineer. It's to make sure the team's knowledge keeps up with the team's output.

== Shared Conventions Matter More

We covered conventions in an earlier chapter. In a team context, the stakes are higher.

When a solo engineer uses agents, their conventions affect one person. When a team uses agents, conventions affect _every agent session across the entire team_. A well-structured project with clear naming, consistent patterns, and a maintained `CLAUDE.md` means every engineer's agents start from a strong foundation.

A messy project means every agent reinvents the wheel. Different engineers get different outputs. The codebase drifts. Reviews get harder because you're now reviewing not just the code but the _style_ of the code, which varies by which engineer's agent wrote it.

Coding standards in an agentic team aren't about aesthetics. They're about _agent effectiveness_. The team that agrees on project structure, naming conventions, testing patterns, and documentation format gets better output from every agent session. It's a force multiplier on a force multiplier.

Invest the time. Write the standards down. Enforce them in CI. It pays back on every single PR.

== The New Standup

What does daily coordination look like when each engineer is running multiple agent sessions in parallel?

The old standup: "Yesterday I worked on the auth refactor. Today I'll continue. No blockers."

The new standup: "I have three agents running. The auth refactor landed and is in review. The API migration is 80% done — the agent got stuck on the legacy XML parsing, so I'm taking that over manually. I just kicked off a third session to generate integration tests for the billing module."

The granularity changes. Work moves faster, so coordination needs to keep up. An engineer might _start and finish_ a task between standups. The daily sync becomes less about progress updates and more about intent alignment — making sure three engineers aren't all sending agents after the same problem from different angles.

Some teams are moving to async standups with more frequent check-ins. Others use shared dashboards that track active agent sessions. The right answer depends on the team, but the old rhythm of "one update per person per day" often isn't enough.

== Compliance and the Audit Trail

If an agent writes code that causes a production incident, who's responsible? The engineer who prompted it? The reviewer who approved the PR? The team lead who decided to adopt agentic workflows? This isn't a philosophical question you debate over pints. It's a legal and compliance question, and regulated industries need clear answers _before_ the incident happens, not during the postmortem.

The good news is that the answer isn't actually that complicated. The tooling and processes already exist. You just need to be explicit about them.

*Git is your audit trail.* Every agent-generated commit should be attributable. The commit message should indicate it was agent-assisted — a `Co-Authored-By` tag, a prefix, whatever convention your team adopts. The PR should show who reviewed it. The merge approval is the sign-off. This is already how most teams work; the key is making it _consistent_. Ad-hoc attribution — sometimes tagging, sometimes not — is worse than no system at all, because it creates the impression of a process without the reliability of one.

*The reviewer owns it.* The practical answer for most organisations is straightforward: the engineer who reviews and approves the PR takes responsibility, same as they would for any code from any source. Agent-generated code doesn't get a different accountability standard. If you approve a PR, you're saying "I've reviewed this and I believe it's correct." The tool that generated the code is irrelevant to that statement. This also means reviews of agent-generated code need to be _real_ reviews, not rubber stamps. If the volume of agent-generated PRs is making thorough review impossible, that's a workflow problem to solve, not a standard to lower.

*For regulated industries.* Document your agentic workflow as part of your SDLC documentation. Which models are used, what version, what guardrails are in place, what review process agent-generated code goes through before it reaches production. Auditors want to see a _process_, not perfection. A documented process that includes "AI-assisted code generation with mandatory human review and CI verification" is auditable. An undocumented process where engineers use whatever tools they like with no consistent approach is not. If you're in fintech, healthcare, or anything with regulatory oversight, get this documented before someone asks for it.

*Keep session logs.* Retain logs of agent sessions, especially for code that touches sensitive systems — billing, authentication, data handling, anything with regulatory implications. Not because you'll read them routinely, but because you might need them during an incident review. "What did the agent see when it generated this code? What prompt produced this output? What context was it working with?" These are questions you want to be able to answer six months later. Most agentic tools can export or log sessions. Set up the retention before you need it. The cost of storage is trivial compared to the cost of not having the logs when compliance comes knocking.

== Hiring Changes

If agents handle the mechanical parts of coding, what do you actually need from an engineer?

Raw coding speed matters less. The engineer who could bang out a perfect binary search on a whiteboard in three minutes has a skill that agents have commoditized. That's not worthless — understanding algorithms still matters — but it's no longer the differentiator.

What matters more:

- *System design.* The ability to decompose a problem into components, define interfaces, and reason about tradeoffs. Agents can implement a design. They can't tell you which design is right for your constraints.
- *Judgment.* Knowing when to use the agent and when to think. Knowing when the agent's output is wrong even though it looks right. Knowing which corners to cut and which to protect.
- *Communication.* The ability to articulate intent clearly — to agents, to teammates, to stakeholders. Vague thinkers get vague agent output. Precise thinkers get precise results.
- *Problem decomposition.* Breaking a large task into agent-sized pieces is a skill. It's related to system design but more tactical. The engineer who can turn a Jira epic into ten well-scoped agent prompts will outperform the one who pastes the whole epic into a chat window.

The interview that asks "implement this algorithm on a whiteboard" is testing a skill that matters less every year. The interview that asks "here's a system with these constraints — walk me through how you'd build it, what tradeoffs you'd make, and how you'd verify it works" is testing the skills that matter _more_ every year.

Hire for judgment. You can always give them an agent for the rest.
