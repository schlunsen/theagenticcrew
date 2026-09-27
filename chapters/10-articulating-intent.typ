= Articulating Intent

There's no secret syntax. No magic incantation that makes an agent produce perfect code. Prompting is _communication_ — and you already know how to communicate.

If you've ever written a good bug report, you know how to prompt. If you've ever written a design doc that a teammate could implement without asking you twenty questions, you know how to prompt. If you've ever filed a Jira ticket that didn't come back as something completely different from what you wanted — you know how to prompt.

The skills transfer directly. Clarity, specificity, context, constraints. The same things that make human collaboration efficient make agent collaboration efficient. The difference is that agents won't ask clarifying questions when your prompt is vague. They'll just guess. And they'll guess confidently.

This is where a lot of experienced engineers quietly struggle. You've spent years building the skill of _doing_ — writing code, debugging, building systems. Now the skill that matters is _articulating_ — explaining what you want with enough precision that someone else can do it. It's a different muscle. And it can feel, in the early days, like a demotion. It's not. But the discomfort is real, and pretending it isn't doesn't help.

== The Anatomy of a Good Task Prompt

A good prompt has three parts: _what_ you want done, _why_ it matters, and _how_ success looks. Most people only provide the first, and even that is usually vague.

Consider the difference:

*Bad:* "Fix the auth bug."

This tells the agent almost nothing. Which auth bug? Where does it manifest? What's the expected behaviour? The agent will go hunting through your codebase, form a theory about what you might mean, and apply a fix that might be entirely wrong. You've turned a five-minute fix into a twenty-minute review of something you didn't ask for.

*Good:* "The login endpoint returns 401 for valid tokens when the session cache is cold. The bug is likely in `middleware/auth.go` in the `validateSession` function. The test in `auth_test.go:TestColdCacheLogin` reproduces it. Fix the bug and make sure all existing auth tests still pass."

This is a different animal entirely. The agent knows the symptom, the suspected location, and how to verify the fix. It can go straight to the relevant code, understand the problem, and validate its solution — all without guessing.

*Tool-equipped:* "The login endpoint returns 401 for valid tokens when the session cache is cold. The failing test is `TestColdCacheLogin`. Investigate, fix it, and make sure all auth tests pass."

Notice what's missing: no file path, no function name. The agent has `grep`, `find`, and the test runner. It can _discover_ where `TestColdCacheLogin` lives and trace the code path itself. What you gave it is the _what_ and the _why_ — the domain knowledge that tools can't provide. The cold cache detail, the symptom, the test name as a starting thread to pull. The agent does the mechanical work of locating the code.

All three levels are useful. Sometimes you _do_ know the exact file and function, and handing that over saves the agent thirty seconds of searching. But the third level represents the mature mental model: provide only what the agent can't find on its own. The problem description, the domain context, the intent. Let the tools handle discovery.

The pattern is simple. _What_ is broken or needed. _Where_ to look (if you already know — don't go hunting just to fill this in). _How_ to verify. Every minute you spend making your prompt precise saves you five minutes reviewing the wrong output.

== Constraint Specification

Telling an agent what to do is only half the job. Telling it what _not_ to do is equally important.

Agents are eager. They optimise for solving the problem you described, and they'll happily refactor your entire module, add three new dependencies, and change the public API to do it. That's not malice — it's an optimiser doing what optimisers do. Your job is to set the boundaries.

Useful constraints look like this:

- "Don't modify the public API surface."
- "Keep the existing test structure — add new test cases, don't reorganise."
- "Don't add new dependencies."
- "Stay within the existing error handling patterns in this codebase."
- "Don't change any files outside of the `services/` directory."

Think of constraints as the guardrails on a bridge. The agent can drive anywhere within the lanes, but it can't go over the edge. Without guardrails, you get creative solutions that technically work but create maintenance nightmares. With them, you get solutions that fit your codebase like they were always there.

The more experienced you become with agentic engineering, the more your prompts are defined by their constraints rather than their instructions. You learn which freedoms lead to good outcomes and which lead to chaos.

== Task Decomposition

A common mistake: asking an agent to build something large in a single prompt. "Build a user dashboard with real-time metrics, role-based access, and export to CSV." That's not a prompt — that's a project. And projects need to be broken into tasks.

Task decomposition is the practice of splitting big requests into small, _verifiable_ steps. Each step has a clear input, a clear output, and a clear way to check whether it worked.

Instead of "build a user dashboard," you write:

+ Create the data model for dashboard metrics in `models/dashboard.go` with the schema defined in the design doc. Write unit tests for the model validation.
+ Build the API endpoint `GET /api/dashboard` that returns metrics for the authenticated user. Write integration tests.
+ Add role-based filtering so admin users see all metrics and regular users see only their own. Update the existing tests to cover both roles.
+ Build the React component that displays the dashboard data. Use the existing `DataTable` component for the metrics grid.

Each step is a self-contained prompt. Each has a verifiable outcome. Each builds on the verified output of the previous step. If step two goes sideways, you catch it before you've wasted time on step three.

This isn't just good prompting — it's good engineering. You're applying the same decomposition skills you'd use when planning a sprint or breaking down a pull request. The unit of work is small enough to review, small enough to test, and small enough to throw away if it's wrong.

== Prompting for Parallelism

Here's something people still miss: you can tell the agent to parallelise.

Sub-agents are now standard in the major agent tools. Each one gets its own context and its own thread of execution. The parent agent hands out the work, waits, and assembles the results. It's right there — but agents default to doing things one at a time, because sequential is safe. Unless you ask.

Say a feature touches three independent modules — the API, the worker, and the notification service. The sequential prompt:

_"Implement the webhook handler in the API module. Then update the worker to process webhook events. Then add notifications for failed webhooks."_

The parallel prompt:

_"This feature touches three independent modules. Launch sub-agents to work on them in parallel: one for the webhook handler in the API module, one for the worker that processes webhook events, and one for the notification service that alerts on failures. Each module has its own directory and its own tests. Merge the results when all three are done."_

Same work, a fraction of the wall-clock time. The key word is _independent_. You have the architectural overview — you know which modules are coupled and which aren't. The agent doesn't always. Your job is to see the parallelism and make it explicit.

A few phrasings that work:

- *"These tasks are independent — run them in parallel."* Direct permission.
- *"Work on the API and the frontend simultaneously — they share the interface in `types.ts` but don't depend on each other's implementation."* Tells the agent _why_ parallelism is safe.
- *"Use a sub-agent to survey how errors are handled across the codebase and report back a summary."* Parallelism for research, too — and it keeps the exploration noise out of your main context.

The same thinking now extends beyond your terminal. Background and cloud agents — OpenAI Codex, GitHub's Copilot coding agent, Cursor's background agents, Claude Code on the web, and others — let you delegate a whole task and get a pull request back later. That changes what a prompt is for. A delegated task can't tap you on the shoulder halfway through, so the prompt has to stand on its own: the outcome, the constraints, how to verify. Everything in this chapter applies twice over.

You're not just telling the agent _what_ to build — you're telling it _how to organise the work_. That's being a tech lead, not a ticket writer.

== The Prompt as a Spec

The best prompts I've seen read like miniature design documents. They describe the desired outcome, not the implementation steps. They list the constraints. They define acceptance criteria. They provide just enough context for the agent to make good decisions without drowning it in irrelevant information.

Here's what a prompt-as-spec looks like:

_"Add rate limiting to the `/api/search` endpoint. Use the existing `RateLimiter` middleware in `middleware/ratelimit.go`. Set the limit to 100 requests per minute per authenticated user, and 20 per minute for unauthenticated requests. Return a 429 status with a `Retry-After` header when the limit is exceeded. Add tests for both the authenticated and unauthenticated paths, including the edge case where a user hits exactly the limit. Don't modify the rate limiter middleware itself — just configure and apply it."_

That's a spec. An agent can implement this without ambiguity. A human reviewer can check the result against the requirements. The desired outcome is clear, the constraints are explicit, and the verification criteria are defined.

A good spec also considers what the agent already has access to. You don't need to write "read the test file and find the failing assertion" if the agent can find it with grep. You _do_ need to specify constraints and intent that aren't discoverable — business rules, performance requirements, the reason this particular behaviour is wrong. Spec the things the tools can't tell the agent. Leave out the things the tools can.

Writing prompts this way takes practice. It also takes discipline — the discipline to think through what you actually want before you start typing. But that discipline pays dividends. A well-specified prompt produces a result you can merge. A vague prompt produces a result you have to rewrite.

== Plan Before You Build

For anything bigger than a small fix, the most useful prompt you can write often isn't "do this." It's "tell me how you'd do this."

Ask for a plan first. Most agent tools now have a plan mode — in Claude Code it's a read-only permission mode where the agent can explore the codebase but can't edit anything — and where they don't, you can simply say it: _"Don't change any code yet. Read the relevant files and propose a plan: which files you'll touch, what you'll change, and how you'll verify it."_

Then read the plan. Properly. This is the cheapest review you'll ever do. A wrong assumption caught in a ten-line plan costs you a sentence of correction. The same wrong assumption caught in a four-hundred-line diff costs you the whole diff. You'll find the agent planning to add a dependency you don't want, or missing the module that actually owns the behaviour, or solving a slightly different problem from the one you meant. Fix it in the plan. Then say "go."

The pattern that's emerged for serious work has three phases:

+ *Research.* The agent explores — reads the code, traces the flow, finds the relevant tests — and writes down what it learned.
+ *Plan.* From that research, it proposes concrete steps. You review and correct.
+ *Implement.* It executes the approved plan, step by step, verifying as it goes.

Between phases, it often pays to start fresh or compact the session, carrying forward only the research notes or the plan. Exploration leaves a lot of noise in the context window, and implementation works better without it. The Context chapter covers why.

Spec-driven development is the formalised version of the same idea. Tools like GitHub's Spec Kit and AWS's Kiro structure the work as spec → plan → tasks before any code gets written, with each artefact saved to the repo where it can be reviewed like anything else. Whether you adopt one of those tools or just keep a `plan.md` next to your branch, the principle is the one from the previous section: the prompt is a spec. Plan mode just makes the agent help you write it — and gives you a checkpoint to catch misunderstandings before they become code.

You don't need this for a one-line fix. You do need it whenever you'd have wanted a design conversation with a human colleague before they started.

== Iteration Over Perfection

Your first prompt won't be perfect. That's fine. Prompting is an iterative process, and the skill isn't in writing the perfect prompt — it's in _reading the output_, understanding where the communication broke down, and refining.

When an agent produces something wrong, resist the urge to blame the tool. Instead, ask yourself: what did I fail to communicate? Did I leave out a constraint? Was the context insufficient? Did I assume knowledge the agent didn't have?

This is debugging — but instead of debugging code, you're debugging your own communication. The error message is the agent's output. The stack trace is your prompt. Somewhere in there is the miscommunication, and finding it makes your next prompt better.

Experienced agentic engineers develop a feedback instinct. They see the agent's output and immediately know which part of their prompt caused the deviation. "Ah, I said 'handle errors' but didn't specify _which_ errors or _how_ to handle them. Of course it threw a generic catch-all in there."

Each iteration tightens the loop. First prompt gets you 70% of the way. A follow-up correction gets you to 90%. A final refinement gets you to done. Over time, your first prompts get better, and you need fewer iterations. But you never need zero.

== Voice-Driven Development

Most of us prompt by typing. That makes sense — we're engineers, we live in text. But there's another input channel that's faster, more natural, and surprisingly underused: your voice.

I'll be honest: the first time I spoke a prompt instead of typing it, I felt ridiculous. There's something deeply awkward about talking to your editor. You feel self-conscious, you stumble, you wonder if this is really how serious engineering gets done. That discomfort stops most people from ever trying again.

Push through it. The payoff is enormous.

Speech-to-text is now good enough that you can talk to your agent and get a near-perfect transcript. Tools like Whisper, macOS Dictation, and SuperWhisper all do the job. Text goes in, code comes out — same as typing. But the experience is fundamentally different.

Typing and speaking are different modes of thinking. When you type, you edit as you go — delete, rephrase, restructure. When you speak, you commit. There's no backspace.

That sounds like a disadvantage. It's actually a training ground.

Speaking forces you to organise your thoughts _before_ you open your mouth. The first few times, you'll ramble. You'll say "um", circle back, contradict yourself — and the agent's output will reflect the mess. But keep at it and you get better. Not just at prompting — at _speaking clearly about technical problems_. You learn to front-load context, state constraints early, and finish with a clear ask.

That skill transfers everywhere: standups, architecture discussions, pair programming, incident calls. Voice-driven development isn't just a faster way to prompt — it's practice for every technical conversation you'll ever have.

=== The Context Advantage

Most people speak at around 130 words per minute and type at 40 to 80. But speed is only half the story. The real advantage is _volume of context_.

Every typed character has a cost — the keystrokes, the spelling, the fatigue that builds over a long session. That cost acts as a filter. You abbreviate. You skip the "obvious" context that's only obvious to you. By the time you hit enter, your prompt is a compressed summary of what you actually know.

Speaking drops that friction to almost nothing. You can describe the full history of a bug — how you noticed it, what you tried, why the obvious fix didn't work, what you suspect. You can narrate your mental model of the system: the intent, the constraints, the tribal knowledge the Context chapter talks about.

I've found my spoken prompts routinely carry two to three times as much useful context as my typed ones. Not because I'm a slow typist, but because typing is _tiring_ in a way speaking isn't. Hours into steering agents through a complex feature, typed prompts get shorter, context gets thinner, and output gets worse. Your voice doesn't decay the way your fingers do. That's the underappreciated argument: voice isn't just faster, it's _more sustainable_.

=== Getting Started with Voice

Try it for a week. Pick a speech-to-text tool, wire it into your workflow, and speak your prompts. The first day will feel awkward. By the third, your spoken prompts will be tighter. By the end of the week, your _spoken communication in general_ will be tighter.

You don't have to go fully live. Speak, let the transcription run, give the text a quick review, then send it. The review catches the worst rambling while keeping the speed and context benefits. You'll need it less over time.

And you don't need a cloud service. Speech recognition runs happily on your own machine — NVIDIA's compact Parakeet models, or whisper.cpp and SuperWhisper using OpenAI's Whisper weights. A modern MacBook transcribes in near real time. There's a pleasing irony in using a local AI to transcribe your voice so another AI can act on it.

The agents don't care whether your prompt was typed or spoken. But _you'll_ be a clearer thinker for having spoken it — and your agent will have far more to work with.

== Visual Context: When Words Aren't Enough

Not everything is easy to describe in text. A broken layout, a weird rendering glitch, an error dialog with a stack trace — sometimes the fastest way to communicate what you're seeing is to _show_ it.

Modern LLMs are multimodal. They can read screenshots, diagrams, photos of whiteboards, and error messages captured from your screen. This is not a novelty feature — it is one of the most underused tools in the agentic engineering workflow.

Here is a workflow I use daily: I see a bug on my phone — a layout that's broken, a modal that's off-centre, a form that's eating input. I screenshot it on iOS, and thanks to Universal Clipboard, I paste it directly into my terminal session on my Mac. The agent sees what I see. No need to describe "the button is overlapping the header on mobile viewport" — the screenshot _is_ the description.

This matters because visual bugs are notoriously hard to describe in text. You end up writing three paragraphs about padding and z-index when a single screenshot communicates the problem instantly. The agent can see the broken state, reason about what's wrong, and propose a fix — often faster than you could finish typing the description.

But it goes beyond bug reports. Some common visual context workflows:

- *Error screenshots.* A browser console full of red, a terminal stack trace, a deployment dashboard showing failed health checks. Screenshot it, paste it, ask the agent to diagnose. This is especially useful when error messages are long or contain formatting that's painful to copy as text.
- *Design references.* A Figma mockup, a sketch, a competitor's UI you want to approximate. Paste the image and say "make our settings page look like this." The agent can extract layout structure, colour choices, and component hierarchy from a visual reference.
- *Debugging visual state.* "Why does this page look wrong?" is a terrible prompt. A screenshot of the page _plus_ "why does this page look wrong?" is a great one. The agent can compare what it sees against the expected layout and identify CSS issues, missing data, or rendering bugs.
- *Whiteboard photos.* After an architecture discussion, snap a photo of the whiteboard and paste it in. The agent can read the boxes, arrows, and labels, and help you translate that sketch into code structure, API definitions, or documentation.

The iOS-to-Mac clipboard pipeline deserves special mention because it removes all friction from this workflow. You don't need to save the screenshot, AirDrop it, find it in Finder, and drag it into a tool. You see the problem, you capture it, you paste it. Three seconds from "that's broken" to "the agent is looking at it." That speed matters because it keeps you in flow. Any extra steps — even thirty seconds of file management — create enough friction that you default back to typing a text description, which is slower and less precise.

The key insight is that _context is not just text_. When we talked about context being the most important ingredient in agentic work, we were talking about all forms of context — code files, documentation, test output, _and_ visual state. A screenshot is worth a thousand tokens, and agents that can see are dramatically more useful than agents that can only read.

If you're not already using visual context in your agentic workflow, start. Screenshot your bugs. Paste your error messages. Share your design references. The agents can see now. Let them.

== Anti-Patterns

Some prompting habits consistently produce poor results. Learn to recognise them.

*Being too vague.* "Make this code better." Better how? Faster? More readable? More maintainable? The agent will pick _something_ to improve, and it probably won't be the thing you had in mind. If you can't articulate what "better" means, you're not ready to prompt.

*Being too prescriptive.* The opposite failure. "On line 47, change the variable name from `x` to `count`, then add an if statement on line 48 that checks if count is greater than zero, then..." You're writing the code in English and asking the agent to translate. That's slower than writing the code yourself. Describe the _outcome_, not the keystrokes.

*Context dumping.* Pasting your entire codebase, all your design docs, and a transcript of your last three team meetings into the prompt. More context is not always better. Irrelevant context is noise, and noise drowns signal. Give the agent what it needs — file paths, function names, the specific behaviour you want — and trust it to explore from there.

*Kitchen-sink prompts.* "Fix the auth bug, also refactor the database layer, and while you're at it update the README and add TypeScript types to the API client." These are four separate tasks jammed into one prompt. The agent will attempt all of them, do none of them well, and produce a diff so large that reviewing it takes longer than doing the work yourself. One prompt, one task.

*Assuming shared context.* "Do it the same way we did the payments module." Unless you've built the memory — an instruction file, the tool's memory feature, notes the agent wrote and re-reads, as the Ship's Log chapter describes — the agent doesn't remember your last session. It certainly doesn't know what "we" decided in standup. And even when the memory exists, don't bet on the agent retrieving the right piece of it. If something matters for this task, say it — or point straight at where it's written down.

*Doing the agent's job for it.* You spend five minutes grepping through the codebase to find the exact file, line number, and function name, then paste all of that into your prompt. That's work the agent's tools can do in seconds. Provide the _problem_ — the symptom, the context, the failing test name. Let the agent investigate. That's what its tools are for. Your time is better spent on the parts the agent _can't_ do: understanding the domain, defining the constraints, knowing why this behaviour is wrong in the first place.

== Prompt Versioning and Evaluation

Here's something most engineers don't think about until it bites them: your prompts are code. They have inputs, outputs, and behaviour. They change over time. And like code, they should be versioned.

The `CLAUDE.md` file is already versioned — it lives in git. But the prompts you type into agent sessions? They're ephemeral. You discover a phrasing that works beautifully for database migrations, use it for a month, then one day rephrase it slightly and the output degrades. You can't diff what you changed because the old prompt was never written down.

The fix is to write them down where the agent can use them. In the first edition of this book I suggested a `prompts/` folder of templates. That still works, but the tools have since given us something better: skills and custom slash commands.

A custom slash command is a Markdown file in your repo — in Claude Code, `.claude/commands/new-endpoint.md` becomes `/new-endpoint` — containing the prompt you'd otherwise retype. A skill goes further: a folder with a `SKILL.md` file (a name, a short description, then the instructions) plus any scripts or reference files it needs. The agent only sees the name and description up front and loads the rest when the task calls for it, so you can keep dozens of them without bloating every session. Agent Skills started in Claude Code and have since been published as an open standard that other tools support.

```
.claude/
  commands/
    debug-test-failure.md   — "This test is failing. Read the error..."
  skills/
    new-endpoint/
      SKILL.md              — our endpoint pattern, contract-first
    db-migration/
      SKILL.md              — migration rules + rollback checklist
      check_migration.sh
```

Either way, the files hold your team's hard-won lessons about communicating with agents. "Include the API contract or the agent will invent its own." "Always specify no new dependencies or you'll get a dependency avalanche." Because they live in git, they get versioned, diffed, and reviewed in pull requests like any other code. When someone improves the migration skill, the whole team gets the improvement on their next pull. The Convention Over Configuration chapter goes deeper on how these fit alongside instruction files.

Evaluation is the other half. When you change a skill or command — or change models, or update your instruction file — how do you know the output got better and not worse? For critical prompts, keep a small set of test cases. Run the prompt against them before and after the change. This isn't formal benchmarking — it's the prompt equivalent of running the test suite before you merge.

The teams that treat prompting as an engineering discipline — versioned, reviewed, evaluated — get consistently better output than the ones who treat it as improvisation.

== Prompting Is a Skill

Prompting is not a parlour trick. It's not about discovering the one weird phrase that unlocks better output. It's a communication skill — and like all communication skills, it improves with practice, feedback, and deliberate attention.

The engineers who get the most out of agentic tools are the ones who treat prompting with the same rigour they apply to writing code. They think before they type. They specify before they implement. They verify before they move on.

That's not a new skill. That's just engineering.
