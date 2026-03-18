= What Is an Agent?

The word "agent" gets thrown around a lot. It's applied to everything from a chatbot that answers questions to a system that autonomously deploys code to production. Before we go further, let's get precise about what we mean — because the distinction matters for how you work with them.

== The Spectrum

Not all AI tools are agents. At one end, *autocomplete* suggests the next few tokens as you type — reactive, one line at a time, no thinking involved. *A copilot* sees more context and generates larger blocks, but it's still passive: you ask, it responds. The shift happens with *tool-using agents*. An agent doesn't just generate text — it _acts_. It reads files, writes files, runs commands, inspects results, and crucially, does this in a loop: try, observe, adjust, try again. At the far end, *autonomous agents* take a high-level goal, plan their own approach, and deliver a result with minimal human interaction.

Most practical agentic engineering today happens in the tool-using zone. You give the agent a task, it has access to tools, and it works iteratively. You're in the loop — reviewing, guiding, approving — but the agent is doing the heavy lifting.

== What Makes Something "Agentic"

Three capabilities separate an agent from a fancy chatbot:

*Planning.* An agent breaks a goal into steps. "Add authentication to this app" becomes a series of actions — read the codebase, pick the framework, create middleware, update routes, add tests, verify. A chatbot gives you a code block. An agent gives you a process.

*Tool use.* An agent interacts with the world — reads your files, runs your tests, examines error output. Each tool call provides new information that shapes the next decision. This feedback loop is what makes agents powerful: they're not generating code in a vacuum, they're generating code and _verifying_ it. And here's the thing people miss: the tools you give an agent define what kind of agent it _is_. An LLM with only text-in, text-out is a chatbot. Give it file access, command execution, and integrations with external systems, and it becomes an engineer. The tools are the promotion.

*Iteration.* An agent can try, fail, and try again. Write a function, run the tests, see a failure, read the error, adjust, rerun. Act, observe, adjust. A chatbot gives you one shot. An agent gives you a cycle.

== Agents Are Not Magic

It's important to be clear-eyed about what agents are and what they aren't.

Agents are not sentient. They don't understand your code the way you do. They don't have intuition, taste, or experience. What they have is the ability to process large amounts of text, recognise patterns, and generate plausible next steps — very quickly, very tirelessly, and at a scale that would exhaust any human.

They hallucinate. They make confident mistakes. They sometimes solve the wrong problem beautifully. They can write code that passes all tests but misses the point entirely. They're brilliant interns with infinite energy and no judgment.

This is why the _engineer_ matters. The agent provides speed and breadth. You provide direction, judgment, and taste. The combination is more powerful than either alone.

== When Agents Fail

They will fail. Understanding _how_ they fail helps you build better workflows.

*Scope creep.* You ask for a bug fix, the agent refactors three files and updates the build system. Agents are eager, and that eagerness extends beyond what you asked for. Small, focused tasks and branch isolation are your defence.

*Hallucinated APIs.* The agent calls functions or libraries that don't exist — or exist in a different version. Running tests catches this. The agent can't hallucinate its way past a test suite.

*Overconfidence.* The agent says it's done, and it looks done, but there's a subtle bug that only shows under specific conditions. Review diffs. Don't blindly trust agent output.

*Context loss.* On long tasks, the agent loses track of earlier decisions — contradicts itself, rewrites code it already wrote, forgets constraints. Small commits and clear context management are the mitigation.

Every failure mode has a mitigation, and those mitigations are the chapters of this book: context, guardrails, git, sandboxes, testing, conventions. The principles aren't theoretical — they're direct responses to how agents fail in practice.

== The Right Mental Model

Don't think of agents as tools. Don't think of them as replacements. Think of them as collaborators with a very specific set of strengths and weaknesses.

They're fast where you're slow. They're patient where you're impatient. They can hold more text in working memory than you can. They never get tired, never get frustrated, never have a bad day.

But they don't know what matters. They don't know what the user actually needs. They don't know which technical debt is acceptable and which is a ticking bomb. They don't know when to push back on a requirement. They don't know when the spec is wrong.

The best analogy I've found is _Rain Man_. You're Tom Cruise. The agent is Dustin Hoffman.

Raymond can count cards like no human alive — he sees patterns in mountains of data, processes them instantly, never gets tired, never loses focus. But he can't navigate a casino floor. He doesn't know _why_ they're counting cards. He doesn't know when to walk away from the table, when the pit boss is getting suspicious, or what to do with the money. Left to his own devices, he'd count cards forever in an empty room.

Charlie is the one with the plan. He knows which casino to hit, when to bet big, when to cash out, when to change strategy entirely. He can't count cards himself — not at Raymond's speed, not at Raymond's scale. But he doesn't need to. His job is direction, judgment, and knowing what the whole operation is _for_.

That's agentic engineering. Your agent will process your entire codebase, generate solutions at a speed you can't match, and iterate tirelessly. But it doesn't know which problem is worth solving. It doesn't know when the elegant solution is the wrong one. It doesn't know when to stop.

That's your job. And it always will be.
