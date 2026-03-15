= What Is an Agent?

The word "agent" gets thrown around a lot. It's applied to everything from a chatbot that answers questions to a system that autonomously deploys code to production. Before we go further, let's get precise about what we mean — because the distinction matters for how you work with them.

== The Spectrum

Not all AI tools are agents. There's a spectrum, and understanding where a tool falls on it changes how you use it.

*Autocomplete* is the simplest form. You type, it suggests the next few tokens. GitHub Copilot's inline suggestions, your IDE's tab completion. It's reactive — it responds to what you're typing, one line at a time. Useful, but it doesn't _think_.

*A copilot* is a step up. It can see more context — your open file, maybe a few related files — and generate larger blocks of code. It can answer questions about your codebase. But it's still fundamentally passive. You ask, it responds. You drive, it assists.

*A tool-using agent* is where things change. An agent doesn't just generate text — it _acts_. It can read files, write files, run commands, execute tests, make API calls, and inspect the results. Critically, it can do this in a loop: try something, observe the outcome, adjust, try again. It has agency — the ability to take actions in the world and respond to feedback.

*An autonomous agent* is the far end of the spectrum. Given a high-level goal, it plans its own approach, breaks the work into steps, executes them, handles errors, and delivers a result — potentially without any human interaction along the way.

Most practical agentic engineering today happens in the "tool-using agent" zone. You give the agent a task, it has access to tools, and it works iteratively to complete it. You're in the loop — reviewing, guiding, approving — but the agent is doing the heavy lifting.

== What Makes Something "Agentic"

Three capabilities separate an agent from a fancy chatbot:

*Planning.* An agent can break a goal into steps. "Add authentication to this app" becomes: read the current codebase, identify the right framework, create the middleware, update the routes, add tests, verify everything passes. A chatbot gives you a code block. An agent gives you a series of actions.

*Tool use.* An agent can interact with the world. It reads your files, runs your tests, checks your git status, examines error output. Each tool call gives it new information, which it uses to decide what to do next. This feedback loop is what makes agents powerful — they're not generating code in a vacuum, they're generating code and _verifying_ it.

*Iteration.* An agent can try, fail, and try again. It writes a function, runs the tests, sees a failure, reads the error, adjusts the code, runs the tests again. This cycle — act, observe, adjust — is the core of agentic behaviour. A chatbot gives you one shot. An agent gives you a process.

== Agents Are Not Magic

It's important to be clear-eyed about what agents are and what they aren't.

Agents are not sentient. They don't understand your code the way you do. They don't have intuition, taste, or experience. What they have is the ability to process large amounts of text, recognise patterns, and generate plausible next steps — very quickly, very tirelessly, and at a scale that would exhaust any human.

They hallucinate. They make confident mistakes. They sometimes solve the wrong problem beautifully. They can write code that passes all tests but misses the point entirely. They're brilliant interns with infinite energy and no judgment.

This is why the _engineer_ matters. The agent provides speed and breadth. You provide direction, judgment, and taste. The combination is more powerful than either alone.

== The Human-Agent Relationship

Think of it like crewing a ship — which is where the title of this book comes from.

You're the captain. You set the course, make the hard calls, and take responsibility for the outcome. The agents are your crew. They handle the work — climbing the rigging, adjusting the sails, keeping watch. They're skilled, they're tireless, and they're good at what they do. But they need direction. They need someone who knows where the ship is going.

A bad captain micromanages every rope. That defeats the purpose of having a crew. A reckless captain gives no direction and wonders why the ship runs aground. The good captain learns which crew members to trust with which tasks, gives clear instructions, checks in at the right moments, and intervenes only when necessary.

That calibration — how much autonomy, for which tasks, with what oversight — is the art of agentic engineering.

== When Agents Fail

They will fail. Understanding _how_ they fail helps you build better workflows.

*Scope creep.* You ask the agent to fix a bug, and it refactors three files, updates the build system, and changes the linting config. Agents are eager to help, and sometimes that eagerness extends beyond what you asked for. This is why small, focused tasks and branch isolation matter.

*Hallucinated APIs.* The agent generates code that calls a function or library that doesn't exist — or exists in a different version. This is why running tests matters. The agent can't hallucinate its way past a test suite.

*Overconfidence.* The agent tells you the task is done, and it looks done, but there's a subtle bug that only manifests under specific conditions. This is why you review diffs and don't blindly trust agent output.

*Context loss.* On long tasks, the agent loses track of earlier decisions. It contradicts itself, rewrites code it already wrote, or forgets constraints you mentioned earlier. This is why small commits and clear context management matter.

Every failure mode has a mitigation, and those mitigations are the chapters that follow: context, guardrails, git, sandboxes, testing, conventions. The principles in this book aren't theoretical — they're direct responses to how agents fail in practice.

== The Right Mental Model

Don't think of agents as tools. Don't think of them as replacements. Think of them as collaborators with a very specific set of strengths and weaknesses.

They're fast where you're slow. They're patient where you're impatient. They can hold more text in working memory than you can. They never get tired, never get frustrated, never have a bad day.

But they don't know what matters. They don't know what the user actually needs. They don't know which technical debt is acceptable and which is a ticking bomb. They don't know when to push back on a requirement. They don't know when the spec is wrong.

That's your job. And it always will be.
