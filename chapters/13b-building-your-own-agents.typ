= Building Your Own Agents

Every time you open Claude Code, Codex or Cursor, you're standing on hundreds of decisions somebody else made.

Someone wrote the system prompt. Someone chose the tools, wrote their descriptions, and decided how much output each one returns before it gets truncated. Someone decided when the conversation gets compacted, what survives the summary, and what quietly doesn't. Someone decided which commands need your approval, how many turns the agent gets, and what happens when a tool throws an exception at step thirty-seven.

When you _use_ an agent, those decisions are invisible. You feel their effects — this tool feels sharp, that one loses the plot after an hour — but you don't see them.

When you _build_ an agent, every one of those decisions is yours.

The first edition of this book was written from the driver's seat. That's still where most engineers meet agents, and it's where most of this book lives. But more and more of us are crossing to the other side of the harness: putting agents inside our own products, our own pipelines, our own internal tools. A support agent that triages tickets. A pipeline that reviews infrastructure changes. A platform like the pentesting system in Appendix A. My own crossing started with the Go port of the Claude Agent SDK I described in the Introduction — you can't port a harness without learning, line by line, what a harness actually does.

This chapter is for that crossing. Everything the book has taught about _using_ agents — context, guardrails, testing, tools, orchestration — still applies. It just looks different from the builder's side. It stops being advice you follow and becomes code you write.

== The Loop Is Small

Here's the uncomfortable truth about agents: the core of one fits on a single page.

The What Is an Agent? chapter described the cycle — the model asks for a tool, the harness runs it, the result goes back, repeat. In code, it looks roughly like this:

```python
# Illustrative — a minimal agent loop, not any specific SDK's API
def run_agent(task, tools, max_turns=20, token_budget=200_000):
    messages = [system_prompt(), user_message(task)]
    spent = 0

    for turn in range(max_turns):
        response = model.generate(messages, tools=schemas(tools))
        messages.append(response)
        spent += response.usage.total_tokens

        if not response.tool_calls:
            return Done(response.text, messages)
        if spent > token_budget:
            return Stopped("budget_exceeded", messages)

        for call in response.tool_calls:
            if call.name not in tools or not permitted(call):
                result = error(f"Tool '{call.name}' is not allowed in this run.")
            else:
                try:
                    result = tools[call.name](**call.arguments)
                except ToolError as e:
                    result = error(str(e))
            messages.append(tool_result(call.id, truncate(result)))

    return Stopped("max_turns", messages)
```

That's an agent. Model, tools, loop. Twenty-five lines.

And that's exactly why so many first attempts disappoint. The loop is the easy part. Everything that makes an agent _good_ lives in the functions this sketch waves away: what `system_prompt()` says, what `truncate()` keeps, what `permitted()` checks, what happens to `messages` when it gets long, what happens when the process dies halfway through turn twelve. The loop is a few dozen lines. The work is everything around it.

You don't have to write the loop yourself. The Claude Agent SDK, the OpenAI Agents SDK and a growing list of frameworks will run it for you, and for most projects you should start with one — they handle streaming, retries, tool schemas and a hundred edge cases you'd otherwise rediscover the hard way. Plain tool use against a model API is also a perfectly respectable starting point. Appendix B has the current landscape.

But write the loop once anyway, even if you throw it away. An afternoon with a hand-rolled loop teaches you more about agent behaviour than a month of reading framework docs. When the framework does something surprising later — and it will — you'll know where to look.

== Start With a Workflow, Earn the Agent

The first instinct, once you've built a loop, is to make everything an agent. Give the model twenty tools and a goal and let it figure out the path.

Resist it.

Most of the value in production agentic systems comes from something much more boring: ordinary, deterministic code with LLM calls at specific points. Fetch the ticket. Ask the model to classify it. Look up the customer. Ask the model to draft a reply. Run the reply through a policy check. Queue it for a human. Every step is known in advance. The model is doing judgement work — classifying, summarising, drafting — inside a path _you_ wrote.

That's a workflow, not an agent. And for a surprising number of problems, it's the right answer. It's cheaper, faster, easier to test, and when it breaks you know which step broke.

The open-ended loop earns its place where the path genuinely can't be known ahead of time. Debugging is the classic case: you don't know which file to read next until you've read the last one. Research is another. So is anything where the next step depends on what the environment says back. That's where "think, act, observe" beats a flowchart.

The pentesting platform in Appendix A is a good illustration of the mix. The five phases are a fixed workflow — recon, then analysis, then exploitation, then reporting. Nobody lets a model decide whether to write the report before running the scan. _Inside_ each phase, focused agents run open-ended loops, because nobody can script in advance how to probe an unfamiliar login form. Deterministic skeleton, agentic muscles.

A useful rule: *the control flow is yours; the model gets the smallest loop that can do the job.* Even inside that loop, the stop conditions belong to your code, not the model's opinion:

- *Maximum turns.* An agent still going after fifty turns on a task that should take ten isn't making progress. It's circling.
- *Budgets.* Tokens, money, wall-clock time. Set all three. Fail loudly when one runs out.
- *Explicit success criteria.* Where you can check "done" in code — tests pass, schema validates, the file exists — check it. Don't take the model's word.
- *A defined failure outcome.* "Stopped: budget exceeded after 14 turns, here's the transcript" is a result. A hung process is not.

The Agents in the Pipeline chapter makes the same point about CI: set a ceiling, fail loudly, make the ceiling easy to adjust. When you're the builder, that ceiling is a line in your code.

== Own the Context

When you use a coding agent, the harness builds the prompt for you. When you build one, you build the prompt — every single turn.

That's the most important mental shift in this chapter. The model has no memory. Each call, it sees exactly what you send it and nothing else. The "conversation" is an illusion your code maintains by resending a list of messages. Which means you get to decide, on every turn, what that list contains.

The Context chapter covers context engineering from the user's side: compaction, notes, sub-agents, just-in-time retrieval. From the builder's side, those aren't techniques you reach for — they're features you implement. Think of each turn's context as assembled from parts:

- *Instructions.* The system prompt: who the agent is, what it's for, what it must never do, what "done" looks like. Keep it stable — it's your contract with the model, and a stable prefix is also friendlier to prompt caching.
- *Relevant state.* Not the whole database — the slice this run needs. The ticket, the customer's plan, the three most recent related incidents. Loaded up front if it's always needed, via a tool if it's sometimes needed.
- *History, compacted.* The raw transcript grows every turn. At some point you summarise older turns into a short "what's happened so far" block and drop the originals. Decide _in advance_ what must survive compaction — decisions made, constraints discovered, the current plan — because the summariser won't know what matters unless you tell it.
- *Tool results, trimmed.* The single biggest source of context bloat. A tool that returns a 4,000-line log file has just spent most of your window on noise. Truncate, paginate, summarise, or store the full output somewhere and return a reference plus the interesting part.

Most of the time, when a home-built agent "gets confused", it's not the model. It's the context. Something important got truncated, or something irrelevant crowded it out, or the history got so long the instructions at the top stopped carrying weight. Print the exact messages you sent on the turn where it went wrong. Nine times out of ten, the answer is right there.

=== Errors Are Context Too

Errors deserve their own mention, because they're where builders most often throw away the agent's best feature.

An agent's superpower is self-correction: try, fail, read the error, adjust. That only works if the error reaches the model in a form it can use. A stack trace with forty frames of framework internals is noise. "Invalid date `2026-13-01`: month must be 1–12" is a signal. When a tool fails, catch the exception, turn it into a short, specific message, and hand it back as the tool result. Don't crash the run, and don't swallow the error and return an empty success.

But self-correction needs a limit. If the same tool fails with the same error three times in a row, the agent isn't learning — it's stuck. Count consecutive failures, and when they cross a threshold, stop the loop and escalate: to a different strategy, to a stronger model, or to a human. The Infinite Loop in the When Agents Get It Wrong chapter is what happens when nobody writes that counter.

== Tools Are the Product

The Extending the Agent's Reach chapter has a section on designing good tools — verb names, descriptions written for the model, described parameters, useful errors, focused tools, limited output. All of it applies, and I won't repeat it. Your tools are an API for the model, and the model is a very literal, very fast, slightly overconfident client.

Building your own agent adds concerns that don't come up when you're just plugging in someone's MCP server — because now _you_ own what happens when the tool runs.

*Classify every tool by its side effects.* I find three buckets enough:

- *Read.* Search, fetch, list, inspect. Safe to call as often as the model likes, within budget.
- *Write.* Creates or changes something that can be undone. A draft, a branch, a comment, a row in a staging table.
- *Irreversible.* Sends an email, charges a card, deletes data, deploys, posts publicly. Things you can't take back.

Then let the classification drive policy. Read tools run freely. Write tools run within the scope of the run. Irreversible tools go through an approval step, or aren't given to the agent at all. This is the Guardrails chapter's allow / ask / deny model, except you're the one writing the rules engine.

*Make write tools idempotent.* Agents retry. Frameworks retry. Your durable workflow engine will replay steps after a crash. If "create the refund" runs twice, you want one refund, not two. Give operations a stable key — derived from the run and the step — and make the tool a no-op if that key has already been processed. It's the same discipline you'd apply to any payment API, and for the same reason.

*Offer a dry-run mode.* For anything consequential, let the tool describe what it _would_ do without doing it: "Would delete 3 records: \#1042, \#1043, \#1047." Dry runs make great approval payloads — the human approves the concrete plan, not a vague intention — and they make the agent far easier to test.

*Return structured errors.* Not just a message, but a shape: what failed, whether retrying might help, and what the model could try instead. `{"error": "not_found", "retryable": false, "hint": "Use search_orders to find the order ID first."}` lets the model — and your loop's escalation logic — make a sensible decision. A bare exception string makes both of them guess.

*Scope tools to the run, not the agent.* A tool that accepts any customer ID is a tool that can be talked into reading any customer's data. Where you can, bind the scope when the run starts: this run is about customer 4812, and the `get_orders` tool it receives can only see customer 4812's orders. The model can't escalate a privilege it was never handed.

== Humans as a Tool Call

In a coding session, the human in the loop is sitting right there. The agent asks, you answer, it continues. That breaks the moment your agent runs inside a product.

Imagine an agent that handles refund requests. It investigates, decides a refund is warranted, and needs a manager's sign-off above a certain amount. The manager is in a meeting. They'll see the Slack message in two hours. Or tomorrow morning.

Your loop can't sit in memory for eighteen hours waiting. The process will be restarted by a deploy long before then.

The design that works: *treat asking a human as just another tool.* `request_approval`, `ask_for_clarification`, `escalate_to_human` — tools with descriptions and schemas like any other. When the model calls one, your harness does something different from a normal tool call:

+ Persist the run — the full conversation, the pending tool call, any business state.
+ Send the question wherever the human actually is — Slack, email, a ticket, a web UI — with enough context to answer without digging.
+ Stop the loop. Free the process. The run is now _paused_, not running.
+ When the answer arrives — a button click, a reply, a webhook — load the run, append the human's response as the tool result, and continue the loop exactly where it left off.

From the model's point of view, nothing unusual happened. It called a tool, and the tool returned "Approved by Sarah: yes, go ahead, but note it on the account." It just took eighteen hours instead of eighteen milliseconds.

Design the human's side as carefully as the model's. The approval message should show what the agent wants to do (ideally the dry-run output), why, and what it's based on. Offer more than yes/no — "approve", "reject", and "reject with a note" at minimum, because the note is the most valuable thing a human can feed back to the agent. And decide what happens when nobody answers: a reminder, an escalation, or an automatic safe default after a timeout. "Waiting forever" is not a policy.

Get this right and humans stop being a bottleneck bolted onto the side. They become a first-class step in the system — which, as the rest of this book argues, is exactly where they belong.

== State and Durability

The moment an agent can pause for a human, it's no longer a function call. It's a long-running process with state. Build for that from day one, even if your first agent finishes in thirty seconds.

*Persist the run.* At minimum, two things: the conversation (every message, every tool call, every result) and the business state (what the run is about, what it's changed, where it is in its workflow). The cleanest shape I know is an append-only event log — "run started", "model responded", "tool called", "tool returned", "human approved", "run finished". The conversation can be rebuilt from the log. So can the business state. So can a timeline for debugging.

That log gives you three properties that matter enormously in production:

- *Resumable.* After a pause, a crash or a deploy, the run picks up from the last recorded event instead of starting over.
- *Restartable.* When a run goes wrong, you can fork it from an earlier point — "replay from turn eight with the corrected tool" — rather than reproducing the whole thing.
- *Inspectable.* When a customer asks "why did the agent do that?", you can answer with the exact sequence of what it saw and what it did. The Ship's Log chapter argues for keeping a record of your own work with agents. For an agent in production, the log isn't a nice habit. It's how you debug, audit, and explain.

For anything that runs longer than a request — minutes, hours, days — reach for a durable workflow engine rather than building your own. Temporal is the one the pentesting platform in Appendix A uses, and it's a good fit: each model call and each tool call becomes a recorded step, a crashed worker resumes where it left off, and a human-approval wait is just a step that waits for a signal. Other durable-execution tools and job-queue patterns can work too; the property you want is that a step, once completed, is never lost and never silently repeated. Chaining scripts together and hoping nothing restarts is how you get agents that forget they already sent the email.

// v2-verify: consider whether to name other durable execution options (e.g. Inngest, Restate, AWS Step Functions) or keep it generic

== Small Agents, Composed

The other seductive mistake is the giant agent. One agent, forty tools, a system prompt the length of a novella, responsible for everything from triage to billing to writing release notes.

It will work in the demo. It will be miserable in production.

Every tool you add is another description competing for the model's attention and another chance to pick the wrong one. Every responsibility you add to the prompt dilutes the others. And when something goes wrong, you can't tell which of the twelve jobs the agent was attempting when it went off the rails.

Build small, focused agents instead. A triage agent with four tools that classifies and routes. A research agent that gathers context and returns a summary. A drafting agent that writes the reply. Each has a short prompt, a handful of tools, and a clear definition of done. Each can be tested on its own, given its own permissions, and run on a model sized for its job — the tiering idea from Appendix A.

Then compose them — usually with ordinary code. The triage agent's output decides which agent runs next. The research agent's summary becomes the drafting agent's input. This is the handover pattern from the Multi-Agent Orchestration chapter, except the handover artefact is a typed object passed between functions instead of a `PLAN.md` in a repo. The same rule holds: make the handover explicit and complete. An agent that starts cold with a vague brief will solve a slightly different problem than the one you meant.

An agent can also call another agent as a tool — "ask the research agent" — which is exactly how sub-agents work in the coding tools. It's the right shape when the orchestrating agent genuinely needs to decide _whether_ and _when_ to delegate. When the order is always the same, keep it in code. Deterministic skeleton, agentic muscles.

== Meet People Where They Are

When you use a coding agent, the trigger is you, typing into a terminal. When you build one, the most useful question is often: _what starts it?_

A chat box is the default everyone reaches for, and it's frequently the wrong one. Most work doesn't begin with someone opening a chat window. It begins with an event:

- *A webhook.* A ticket is created, a payment fails, a deploy finishes, a form is submitted. The agent runs because something happened.
- *A schedule.* Every morning, summarise overnight alerts. Every six hours, check what changed — the sentinel mode from Appendix A.
- *Chat.* A mention in Slack or Teams, where the conversation is already happening. The agent replies in the thread, and the thread becomes its context.
- *Email.* Still the universal API. An agent that reads an inbox and replies — carefully — reaches people who will never open your app.
- *CI.* A PR is opened, a build fails, a release is tagged. The Agents in the Pipeline chapter covers this in depth.

The best agents don't feel like "an AI feature". They feel like a colleague who notices things. The ticket arrives already triaged. The failed build arrives with a diagnosis attached. The morning summary is waiting in the channel. Nobody had to remember to ask.

Two things change when agents run on triggers rather than prompts. First, nobody is watching — so every guardrail, budget and escalation path above stops being optional. Second, the input is whatever the event contains, which brings us straight to security. But first, the question every builder eventually faces: how do you know it works?

== Evals Are Your Test Suite

When you use an agent, you verify its output — you read the diff, you run the tests. When you build one, you need to verify its _behaviour_, across thousands of runs you'll never read. That's what evals are for.

An eval is a test suite for agent behaviour. A set of realistic tasks, each with a way to check the result:

- A support ticket, with the expected category and the facts the reply must contain.
- A buggy repository, with a test that should pass after the agent's fix.
- A refund request, with the correct decision and the rule that justifies it.
- An adversarial input, with the thing the agent must _not_ do.

Start with twenty. Pull them from real traffic wherever you can — the weird cases are the valuable ones. Every time the agent fails in production, turn that failure into a new eval case. That's exactly the regression-test habit from the Testing as the Feedback Loop chapter, and it's just as effective here.

Then run the suite on every change that could alter behaviour. A prompt tweak. A new tool. A reworded tool description. A model upgrade. Especially a model upgrade — a new model can be better on average and worse on _your_ tasks, and you won't know which without measuring. A prompt change without an eval run is an untested deploy.

Some practical lessons:

*Check in code wherever you can.* Did the agent call the right tool? Is the output valid JSON matching the schema? Did the test pass? Did it avoid the forbidden action? Deterministic checks are cheap, fast and don't drift. Push as much of your eval into them as possible.

*Use LLM-as-judge with care.* For things code can't check — is this reply helpful, accurate, polite? — you can ask a model to grade the output. It's useful, and it's a second model with its own biases. Give the judge a specific rubric, not "rate this 1–10". Grade one property at a time. And spot-check the judge against your own judgement regularly; a judge that disagrees with you is measuring something, just not the thing you care about.

*Expect variance.* Agents are non-deterministic. A task that passes four times out of five is not "passing". Run important cases several times and track pass rates, not single results.

*Trace every run.* Not just in evals — in production. Every model call, every tool call, every result, every token count, with timings. When an eval fails, the trace tells you _why_. When a customer complains, the trace tells you what happened. The event log from the durability section gives you most of this for free. Several observability tools now specialise in agent traces; Appendix B lists some.

*Watch cost and latency as first-class metrics.* An agent that gets the right answer in forty turns and three minutes may be worse than one that gets it right nine times out of ten in four turns and ten seconds. Put both numbers next to the pass rate on every eval run, so a "better" prompt that doubles your bill doesn't sneak through.

The builders who ship reliable agents aren't the ones with the cleverest prompts. They're the ones with the best evals. The eval suite is what lets you change things with confidence — which, when models change underneath you every few months, is the only way to keep a product standing.

== Security From the Builder's Side

The Agent Attack Surface chapter covers prompt injection, the lethal trifecta and the real incidents that followed. Read it before you ship anything. From the builder's side, it comes down to a few design rules.

*Every input is untrusted.* The ticket text, the email body, the web page your research tool fetched, the output of another agent — any of it can contain instructions, and the model can't reliably tell data from commands. Design as if some of it will.

*Least privilege per run.* Don't give the agent a service account that can see everything and then hope the prompt keeps it in line. Give each run credentials scoped to exactly what that run needs — this customer, this repository, this table, read-only unless writing is the point. The Supabase and GitHub MCP incidents covered in that chapter both came down to an agent holding far more privilege than its task needed.

*Break the trifecta by design.* If a run reads untrusted input, think hard before also giving it private data _and_ a way to send things out. Often you can split the work: one agent reads the untrusted input and produces a constrained, structured summary; a second agent, which never sees the raw input, acts on it.

*Irreversible actions go through a human or a deterministic check.* That's the side-effect classification from earlier, doing its security job. An injected instruction that can only produce a _request_ for approval is far less dangerous than one that can produce the action itself.

When you use an agent, security is about what you allow. When you build one, it's about what you make possible. Make less possible.

== The View From Both Sides

Something unexpected happens once you've built an agent or two: you get noticeably better at _using_ them.

You stop being surprised. When a coding agent loses the thread after a long session, you know it's a context problem, not a mood — and you know to compact or start fresh. When it picks the wrong tool, you think about the descriptions it was shown. When it declares victory too early, you think about the stop conditions and reach for a test it has to pass. When it asks permission for something harmless, you understand the rule that fired and whether to loosen it.

The harness stops being a black box. You see the loop, the context being assembled turn by turn, the tools as an API, the guardrails as code someone wrote. Everything in the rest of this book starts to look less like a set of tips and more like what it actually is: the design of a system, seen from the outside.

That's the real lesson of the crossing. The agent was never magic. It was a model, some tools, a loop and an environment — and a great many decisions. Once you've made those decisions yourself, you'll never look at someone else's quite the same way again.

Build one. Even a small one. You'll be a better captain for it.
