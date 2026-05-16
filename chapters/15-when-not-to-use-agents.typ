= When Not to Use Agents

This book is about using agents well. This chapter is about knowing when not to use them at all.

If you've read this far, you're probably sold on agentic engineering. Good. But the fastest way to lose credibility — and waste time — is to reach for an agent when the job calls for a human. The best agentic engineers aren't the ones who use agents the most. They're the ones who know _exactly_ when to put the agent away and do the work themselves.

== The Overhead Tax

Every agent interaction has a cost. You write the prompt. You wait for the output. You review what it produced. You fix the mistakes. You re-run if it missed the point. That's overhead, and it's real.

For complex tasks that would take you an hour, spending two minutes on prompt and review is a bargain. But for tasks you can do in thirty seconds? The overhead makes agents _slower_, not faster.

Renaming a variable. Fixing a typo. Tweaking a config value. Adding a log line. These are muscle-memory tasks. Your fingers know the keystrokes. By the time you've typed a prompt describing what you want, you could have already done it.

This isn't a failure of agents. It's arithmetic. Small tasks have small payoffs, and the fixed cost of agent interaction eats the margin. Don't let the novelty of agents trick you into using them for everything. Some work is just faster by hand.

== Novel Architecture Decisions

When you're designing a system from scratch — choosing between a monolith and microservices, deciding on your data model, picking your communication patterns — the _thinking is the work_. The value isn't in the diagram or the document. The value is in the mental model you build while wrestling with the tradeoffs.

An agent can help you explore options. It can list the pros and cons of event sourcing versus CRUD. It can sketch out what a particular architecture might look like. That's useful as input.

But delegating the architecture itself to an agent means you don't understand your own system. You'll struggle to debug it, extend it, or explain it to your team. The senior engineer's job is to make the hard calls — to weigh the tradeoffs that don't have clean answers, to decide what complexity is worth carrying and what isn't. That judgment comes from doing the work, not from reading an agent's summary of it.

Use agents as a sparring partner for architecture. Not as the architect.

== Security-Critical Code

Authentication flows. Encryption. Access control. Input validation. Token handling. These are areas where "looks correct" isn't good enough.

Security bugs are different from regular bugs. A broken sort function produces wrong output that someone notices. A broken auth check produces _no visible symptoms_ until an attacker finds it. The code looks fine. The tests pass. And six months later you're writing an incident report.

Agents produce plausible code. That's their strength and, in security contexts, their danger. A subtle flaw in a JWT validation flow, a missing check on a redirect URL, a timing side-channel in a password comparison — these are the kinds of mistakes that survive code review because they _look right_.

Write security-critical code yourself. Review it carefully. Get a second pair of human eyes on it. If you do use an agent to draft security code, treat that draft with more suspicion than you'd give a junior developer's first attempt, not less.

== When You Need to Learn

You're picking up a new language. A new framework. A new paradigm. The temptation is obvious: let the agent write the code while you focus on the big picture.

Resist it.

If you let the agent write all the Rust while you're learning Rust, you haven't learned Rust. You've built something you can't maintain, debug, or extend without the agent. You've created a dependency, not a skill.

There's a crucial difference between using an agent to _explain_ something and using it to _do_ something. Asking "why does this borrow checker error occur?" builds understanding. Asking "fix this borrow checker error" doesn't.

When the goal is learning, slow down. Write the code yourself. Make the mistakes yourself. Use agents as tutors, not ghostwriters. The understanding you build by struggling through the hard parts is the whole point.

== Emotionally Charged Decisions

Not every engineering decision is technical. Some of the hardest ones are human.

Deprecating an API that a partner depends on. Telling a stakeholder their feature request won't make the cut. Pushing back on a deadline you know is unrealistic. Deciding to sunset a product that still has users.

These decisions require empathy. They require reading the room, understanding the politics, weighing the human cost alongside the technical cost. They require _accountability_ — someone who will own the decision and its consequences.

An agent can draft the email. It can help you think through the talking points. But the decision itself, and the conversation that delivers it, must come from a human. People deserve to hear hard news from a person, not from someone who copy-pasted an agent's output.

== When the Codebase Is Too Messy

Agents amplify what's already there. In a clean, well-structured codebase with strong conventions, agents produce clean, well-structured code. They pick up the patterns and follow them.

In a mess? They produce more mess.

If your codebase has inconsistent naming, tangled dependencies, no clear module boundaries, and three different ways to do the same thing — an agent will pick up _all_ of those patterns. It might combine the worst parts of each. It doesn't know which patterns are intentional and which are technical debt. It just sees what's there and produces more of it.

Sometimes the right move is to clean up before you bring agents in. Refactor the module. Establish the convention. Delete the dead code. Make the codebase a place where an agent can do good work. This is unglamorous, manual labor. But it's the foundation that makes everything else possible.

Think of it like a workshop. You don't hand power tools to someone in a cluttered, disorganized shop. You clean up first, _then_ bring in the tools.

== Working with Legacy Code

That workshop metaphor is nice. But not everyone has the luxury of cleaning up first. Some of us maintain 500,000-line Java monoliths that were started in 2014 and have been through three framework migrations, two acquisitions, and a brief period where someone thought XML configuration was a good idea. The advice to "refactor before bringing in agents" is sound in theory and laughable in practice when you're staring at a codebase that would take years to refactor.

So how _do_ you use agents in legacy code? Carefully. And with a specific strategy.

*Start with the tests.* Before pointing an agent at legacy code, write characterisation tests — tests that capture what the code _currently_ does, not what it _should_ do. These aren't aspirational. They're descriptive. They say "when you call this function with these inputs, this is what comes out, and that's the current contract whether anyone intended it or not."

Characterisation tests give the agent a safety net. Without them, the agent will change behaviour it doesn't understand, and you won't know until production tells you. With them, any behavioural change shows up as a test failure _before_ the code leaves your machine. This is non-negotiable. Legacy code without tests is legacy code you can't safely let agents touch.

*Scope ruthlessly.* In a legacy codebase, the agent can't understand the whole system. Don't try to make it. Point it at one file, one function, one bug. Give it the immediate context — the function signature, the callers, the expected behaviour — and nothing else. Legacy code is full of implicit assumptions, undocumented side effects, and load-bearing quirks. The less the agent sees, the less it can misinterpret. A narrow scope with clear context beats a broad scope with archaeological complexity.

*Use agents for the tedious parts.* Legacy codebases are full of mechanical work: updating deprecated API calls across hundreds of files, migrating from one dependency version to another, adding type annotations to untyped code, standardising error handling patterns, replacing one logging framework with another. These are _perfect_ agent tasks — repetitive, well-defined, easily verified by automated checks. Let agents do the drudgery. Save your energy for the parts that require understanding _why_ the code is the way it is. That's the work only a human who's lived with the system can do.

*Document as you go.* Every time an agent works on a legacy file successfully, add a brief comment explaining what the code does, or update the project's `CLAUDE.md` with context about that module. Over time, something interesting happens: the parts of the legacy codebase that agents have touched become better documented than the parts they haven't. Not because you set out to document the system, but because using agents _forced_ you to articulate what each piece does in order to prompt effectively. The agents are slowly making the codebase more legible — not by refactoring it, but by making you explain it.

== The Craft Argument

There's one more reason to sometimes put the agent away, and it's not about efficiency or risk. It's about craft.

Writing code by hand builds something that agents can't give you. Muscle memory. Pattern recognition that lives in your fingers, not just your head. The deep, intuitive understanding that comes from having written the same kind of function dozens of times. The quiet satisfaction of solving a hard problem through your own reasoning.

These things matter. Not because they're romantic, but because they make you a better engineer. The developer who has hand-written a parser understands parsing differently than one who has only prompted an agent to write one. The developer who has debugged a concurrency issue at 2am _feels_ the danger of shared mutable state in a way that reading about it never provides.

Agents are tools. Powerful ones. But if you let them do all the work, your own skills atrophy. And when you hit a problem that the agent can't solve — and you will — you need those skills to still be sharp.

Stay in practice. Write code by hand regularly. Not because it's faster, but because it keeps you dangerous.

== The Judgment That Matters

The central skill of agentic engineering isn't prompting. It isn't tool configuration. It isn't knowing which model to use for which task.

It's _judgment_.

Knowing when an agent will save you an hour and when it will waste one. Knowing when to trust the output and when to rewrite it from scratch. Knowing when to delegate and when to dig in yourself.

The best agentic engineers use agents aggressively — but selectively. They reach for agents when the leverage is real: large-scale refactors, boilerplate generation, code exploration, test writing, documentation. And they put the agent away when the work requires human thinking, human accountability, or human craft.

That judgment is what separates agentic engineers from prompt jockeys. Anyone can type a prompt. Knowing _when not to_ is the harder skill.
