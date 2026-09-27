= What Is an Agent?

The word "agent" gets thrown around a lot. It's applied to everything from a chatbot that answers questions to a system that autonomously deploys code to production. Before we go further, let's get precise about what we mean — because the distinction matters for how you work with them.

== The Spectrum

Not all AI tools are agents. At one end, *autocomplete* suggests the next few tokens as you type — reactive, one line at a time, no thinking involved. *A copilot* sees more context and generates larger blocks, but it's still passive: you ask, it responds. The shift happens with *tool-using agents*. An agent doesn't just generate text — it _acts_. It reads files, writes files, runs commands, inspects results, and crucially, does this in a loop: try, observe, adjust, try again. At the far end, *autonomous agents* take a high-level goal, plan their own approach, and deliver a result with minimal human interaction.

When I wrote the first edition, most practical agentic engineering happened in the tool-using zone: you gave the agent a task, watched it work in your terminal, and approved things as it went. That's still the core of the craft. But the centre of gravity has shifted toward the autonomous end. It's now routine to hand an agent a task, close the laptop, and come back to a pull request. The spectrum hasn't changed shape. We've just moved further along it.

What hasn't moved is who's in charge. You're still in the loop — reviewing, guiding, approving — even when the loop is a PR review the next morning instead of a prompt in your terminal.

== What Makes Something "Agentic"

Three capabilities separate an agent from a fancy chatbot:

*Planning.* An agent breaks a goal into steps. "Add authentication to this app" becomes a series of actions — read the codebase, pick the framework, create middleware, update routes, add tests, verify. A chatbot gives you a code block. An agent gives you a process.

*Tool use.* An agent interacts with the world — reads your files, runs your tests, examines error output. Each tool call provides new information that shapes the next decision. This feedback loop is what makes agents powerful: they're not generating code in a vacuum, they're generating code and _verifying_ it. And here's the thing people miss: the tools you give an agent define what kind of agent it _is_. An LLM with only text-in, text-out is a chatbot. Give it file access, command execution, and integrations with external systems, and it becomes an engineer. The tools are the promotion.

*Iteration.* An agent can try, fail, and try again. Write a function, run the tests, see a failure, read the error, adjust, rerun. Act, observe, adjust. A chatbot gives you one shot. An agent gives you a cycle.

== The Anatomy of an Agent

Strip away the branding and every coding agent is built from the same four parts:

- *A model.* The LLM. It reads text and produces text. That's all it does.
- *Tools.* A list of things the agent is allowed to ask for — read a file, edit a file, run a shell command, search the web, query a database.
- *A loop.* Code that keeps calling the model, running whatever it asks for, and feeding the results back until the work is done.
- *An environment.* The machine, container, or cloud sandbox the tools actually operate on — your repo, your shell, your test suite.

The model is the part everyone talks about. The other three are the parts that make it an agent.

== How Tool Calling Actually Works

We talk about agents "calling" tools as if it were a function call in your code. It isn't, and understanding what actually happens explains a lot of agent behaviour that otherwise seems mysterious.

The model never executes anything. It generates text. A tool call is just a structured form of that text — output in an agreed format that some other program reads and acts on. Here's the cycle:

+ *You send a prompt.* "Why is the checkout test failing?"
+ *The model sees the available tools.* Along with your message, the model receives a list of every tool it can use — names, descriptions, and input schemas. The agent's software injects these before the model sees your message.
+ *The model decides to call a tool.* Instead of replying in prose, it outputs a structured request: a tool name and some arguments, formatted as JSON. "Run `npm test -- checkout`." It's not running anything. It's _asking_.
+ *The harness executes it.* The surrounding program validates the arguments, checks whether it's allowed, and actually does the thing — runs the command, reads the file, hits the API.
+ *The result goes back to the model.* The output — test results, file contents, an error — is appended to the conversation, and the model generates its next response with that new information in view.
+ *Repeat.* The model might call another tool, or it might answer you. A real task can involve dozens of tool calls in sequence, each informed by the results of the last.

That's the whole trick. The model _thinks_ about what to do, _acts_ by requesting a tool call, _observes_ the result, and _thinks_ again. It's a reasoning loop with real-world side effects — and the side effects all happen outside the model.

Understanding this loop explains several things that trip up new agent users:

*Why agents sometimes call the wrong tool.* The model picks tools based on their descriptions and the conversation so far. If two tools sound alike, it might pick the wrong one. If a description is vague, it guesses. Tool selection is a _language_ task — pattern-matching your request against descriptions — not a lookup table.

*Why agents sometimes pass wrong arguments.* Arguments are generated text too. A parameter called `id` with no description could be a user ID, an order ID, or a row ID. The model guesses from context, and sometimes guesses wrong.

*Why agents sometimes call tools unnecessarily.* The model has no built-in sense of cost. It doesn't know that a query takes ten seconds or that an API call costs money. If a tool _might_ be relevant, it may call it — even when the answer is already in front of it.

*Why agents get better with better descriptions.* The model's _only_ knowledge of a tool is its name, description, and parameter schema. Better descriptions lead to better choices and better arguments — the difference between an agent that works and one that flails. We'll put this to work in the Extending the Agent's Reach chapter.

== The Harness

The program running that loop has a name: the *harness*. Claude Code, Codex, Cursor, Copilot's agent mode, Gemini CLI, Aider, opencode — these are all harnesses. Many of them can drive more than one model, and the same model behaves noticeably differently in different harnesses.

That's because the harness makes most of the decisions that matter in practice:

*Permissions.* The model asks to run `rm -rf build/`. Does it happen? The harness decides — automatically, after asking you, or never. Every approval prompt you've ever clicked came from the harness, not the model. The Guardrails chapter is largely about configuring this layer.

*Context management.* Every tool result gets appended to the conversation, and the conversation has a finite size. The harness decides what stays in the window, what gets truncated, and when a long session gets _compacted_ — summarised into a fresh context so the work can continue. How well it does this is a big part of why one tool feels sharp after an hour and another feels confused. The Context chapter covers this in depth.

*When to stop.* The model can say "I'm done," but the harness enforces the real limits — a maximum number of turns, a budget, a timeout, a stop hook that runs your tests before the agent is allowed to finish.

*Where the tools run.* Your laptop, a container, or a sandbox in someone's cloud. The harness chooses the environment, and the environment defines the blast radius.

Once you see this split, a lot of confusion disappears. When an agent does something reckless, the question isn't only "why did the model suggest that?" It's also "why did the harness let it happen?" The first you can influence. The second you control.

== The Modern Shape

The basic loop hasn't changed since the first edition. What's changed is what gets built on top of it.

*Sub-agents.* A harness can start another instance of the loop — a sub-agent — with its own fresh context and a narrower job: "search the codebase for every caller of this function and report back." The sub-agent does the messy exploration, and only a condensed answer returns to the main session. It's delegation, and it's one of the most effective ways to keep a long task from drowning in its own context.

*Background and cloud agents.* The loop no longer has to run in your terminal. You can assign an issue to an agent, it spins up a sandboxed environment in the cloud, does the work, runs the tests, and opens a pull request. OpenAI's Codex, GitHub's Copilot coding agent, Cursor's background agents, Google's Jules, and Claude Code on the web all work this way. The "leave it running overnight" pattern that used to take custom scripting is now a button.

None of these are new kinds of agent. They're the same model, tools, loop, and environment — composed differently. Which is good news: if you understand the loop, you understand all of them.

== Agents Are Not Magic

It's important to be clear-eyed about what agents are and what they aren't.

Agents are not sentient. They don't understand your code the way you do. They don't have intuition, taste, or experience. What they have is the ability to process large amounts of text, recognise patterns, and generate plausible next steps — very quickly, very tirelessly, and at a scale that would exhaust any human.

They hallucinate. They make confident mistakes. They sometimes solve the wrong problem beautifully. They can write code that passes all tests but misses the point entirely. They're brilliant interns with infinite energy and no judgment.

The models have got markedly better since the first edition. They plan further ahead, recover from errors more gracefully, and can work unattended for much longer. None of that changes the paragraph above. A more capable intern is still an intern.

This is why the _engineer_ matters. The agent provides speed and breadth. You provide direction, judgment, and taste. The combination is more powerful than either alone.

== When Agents Fail

They will fail. Understanding _how_ they fail helps you build better workflows.

*Scope creep.* You ask for a bug fix, the agent refactors three files and updates the build system. Agents are eager, and that eagerness extends beyond what you asked for. Small, focused tasks and branch isolation are your defence.

*Hallucinated APIs.* The agent calls functions or libraries that don't exist — or exist in a different version. Running tests catches this. The agent can't hallucinate its way past a test suite.

*Overconfidence.* The agent says it's done, and it looks done, but there's a subtle bug that only shows under specific conditions. Review diffs. Don't blindly trust agent output.

*Context loss.* On long tasks, the agent loses track of earlier decisions — contradicts itself, rewrites code it already wrote, forgets constraints. Bigger context windows haven't made this go away; quality degrades well before the window is full, and compaction can quietly drop a detail that mattered. Small commits, written-down plans the agent can re-read, and starting a fresh session between phases of work are the mitigation. The Context chapter covers this in detail.

Every failure mode has a mitigation, and those mitigations are the chapters of this book: context, guardrails, git, sandboxes, testing, conventions. The principles aren't theoretical — they're direct responses to how agents fail in practice.

== The Right Mental Model

Don't think of agents as tools. Don't think of them as replacements. Think of them as collaborators with a very specific set of strengths and weaknesses.

They're fast where you're slow. They're patient where you're impatient. They can hold more text in working memory than you can. They never get tired, never get frustrated, never have a bad day.

But they don't know what matters. They don't know what the user actually needs. They don't know which technical debt is acceptable and which is a ticking bomb. They don't know when to push back on a requirement. They don't know when the spec is wrong.

The best analogy I've found is _Rain Man_. You're Tom Cruise. The agent is Dustin Hoffman.

Raymond can count cards like no human alive — he sees patterns in mountains of data, processes them instantly, never gets tired, never loses focus. But he can't navigate a casino floor. He doesn't know _why_ they're counting cards. He doesn't know when to walk away from the table, when the pit boss is getting suspicious, or what to do with the money. Left to his own devices, he'd count cards forever in an empty room.

Charlie is the one with the plan. He knows which casino to hit, when to bet big, when to cash out, when to change strategy entirely. He can't count cards himself — not at Raymond's speed, not at Raymond's scale. But he doesn't need to. His job is direction, judgment, and knowing what the whole operation is _for_.

That's agentic engineering. Your agent will process your entire codebase, generate solutions at a speed you can't match, and iterate tirelessly. But it doesn't know which problem is worth solving. It doesn't know when the elegant solution is the wrong one. It doesn't know when to stop.

The agents have got faster at counting cards, and they'll now happily play a few tables on their own while you're out of the room. But someone still has to decide which casino, and when to cash out.

That's your job. And it always will be.
