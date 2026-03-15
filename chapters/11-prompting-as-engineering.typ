= Prompting as Engineering

There's no secret syntax. No magic incantation that makes an agent produce perfect code. Prompting is _communication_ — and you already know how to communicate.

If you've ever written a good bug report, you know how to prompt. If you've ever written a design doc that a teammate could implement without asking you twenty questions, you know how to prompt. If you've ever filed a Jira ticket that didn't come back as something completely different from what you wanted — you know how to prompt.

The skills transfer directly. Clarity, specificity, context, constraints. The same things that make human collaboration efficient make agent collaboration efficient. The difference is that agents won't ask clarifying questions when your prompt is vague. They'll just guess. And they'll guess confidently.

== The Anatomy of a Good Task Prompt

A good prompt has three parts: _what_ you want done, _why_ it matters, and _how_ success looks. Most people only provide the first, and even that is usually vague.

Consider the difference:

*Bad:* "Fix the auth bug."

This tells the agent almost nothing. Which auth bug? Where does it manifest? What's the expected behaviour? The agent will go hunting through your codebase, form a theory about what you might mean, and apply a fix that might be entirely wrong. You've turned a five-minute fix into a twenty-minute review of something you didn't ask for.

*Good:* "The login endpoint returns 401 for valid tokens when the session cache is cold. The bug is likely in `middleware/auth.go` in the `validateSession` function. The test in `auth_test.go:TestColdCacheLogin` reproduces it. Fix the bug and make sure all existing auth tests still pass."

This is a different animal entirely. The agent knows the symptom, the suspected location, and how to verify the fix. It can go straight to the relevant code, understand the problem, and validate its solution — all without guessing.

The pattern is simple. _What_ is broken or needed. _Where_ to look. _How_ to verify. Every minute you spend making your prompt precise saves you five minutes reviewing the wrong output.

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

Here's a common mistake: asking an agent to build something large in a single prompt. "Build a user dashboard with real-time metrics, role-based access, and export to CSV." That's not a prompt — that's a project. And projects need to be broken into tasks.

Task decomposition is the practice of splitting big requests into small, _verifiable_ steps. Each step has a clear input, a clear output, and a clear way to check whether it worked.

Instead of "build a user dashboard," you write:

+ Create the data model for dashboard metrics in `models/dashboard.go` with the schema defined in the design doc. Write unit tests for the model validation.
+ Build the API endpoint `GET /api/dashboard` that returns metrics for the authenticated user. Write integration tests.
+ Add role-based filtering so admin users see all metrics and regular users see only their own. Update the existing tests to cover both roles.
+ Build the React component that displays the dashboard data. Use the existing `DataTable` component for the metrics grid.

Each step is a self-contained prompt. Each has a verifiable outcome. Each builds on the verified output of the previous step. If step two goes sideways, you catch it before you've wasted time on step three.

This isn't just good prompting — it's good engineering. You're applying the same decomposition skills you'd use when planning a sprint or breaking down a pull request. The unit of work is small enough to review, small enough to test, and small enough to throw away if it's wrong.

== The Prompt as a Spec

The best prompts I've seen read like miniature design documents. They describe the desired outcome, not the implementation steps. They list the constraints. They define acceptance criteria. They provide just enough context for the agent to make good decisions without drowning it in irrelevant information.

Here's what a prompt-as-spec looks like:

_"Add rate limiting to the `/api/search` endpoint. Use the existing `RateLimiter` middleware in `middleware/ratelimit.go`. Set the limit to 100 requests per minute per authenticated user, and 20 per minute for unauthenticated requests. Return a 429 status with a `Retry-After` header when the limit is exceeded. Add tests for both the authenticated and unauthenticated paths, including the edge case where a user hits exactly the limit. Don't modify the rate limiter middleware itself — just configure and apply it."_

That's a spec. An agent can implement this without ambiguity. A human reviewer can check the result against the requirements. The desired outcome is clear, the constraints are explicit, and the verification criteria are defined.

Writing prompts this way takes practice. It also takes discipline — the discipline to think through what you actually want before you start typing. But that discipline pays dividends. A well-specified prompt produces a result you can merge. A vague prompt produces a result you have to rewrite.

== Iteration Over Perfection

Your first prompt won't be perfect. That's fine. Prompting is an iterative process, and the skill isn't in writing the perfect prompt — it's in _reading the output_, understanding where the communication broke down, and refining.

When an agent produces something wrong, resist the urge to blame the tool. Instead, ask yourself: what did I fail to communicate? Did I leave out a constraint? Was the context insufficient? Did I assume knowledge the agent didn't have?

This is debugging — but instead of debugging code, you're debugging your own communication. The error message is the agent's output. The stack trace is your prompt. Somewhere in there is the miscommunication, and finding it makes your next prompt better.

Experienced agentic engineers develop a feedback instinct. They see the agent's output and immediately know which part of their prompt caused the deviation. "Ah, I said 'handle errors' but didn't specify _which_ errors or _how_ to handle them. Of course it threw a generic catch-all in there."

Each iteration tightens the loop. First prompt gets you 70% of the way. A follow-up correction gets you to 90%. A final refinement gets you to done. Over time, your first prompts get better, and you need fewer iterations. But you never need zero.

== Anti-Patterns

Some prompting habits consistently produce poor results. Learn to recognise them.

*Being too vague.* "Make this code better." Better how? Faster? More readable? More maintainable? The agent will pick _something_ to improve, and it probably won't be the thing you had in mind. If you can't articulate what "better" means, you're not ready to prompt.

*Being too prescriptive.* The opposite failure. "On line 47, change the variable name from `x` to `count`, then add an if statement on line 48 that checks if count is greater than zero, then..." You're writing the code in English and asking the agent to translate. That's slower than writing the code yourself. Describe the _outcome_, not the keystrokes.

*Context dumping.* Pasting your entire codebase, all your design docs, and a transcript of your last three team meetings into the prompt. More context is not always better. Irrelevant context is noise, and noise drowns signal. Give the agent what it needs — file paths, function names, the specific behaviour you want — and trust it to explore from there.

*Kitchen-sink prompts.* "Fix the auth bug, also refactor the database layer, and while you're at it update the README and add TypeScript types to the API client." These are four separate tasks jammed into one prompt. The agent will attempt all of them, do none of them well, and produce a diff so large that reviewing it takes longer than doing the work yourself. One prompt, one task.

*Assuming shared context.* "Do it the same way we did the payments module." The agent doesn't remember your last session. It doesn't know what "we" decided in standup. Every prompt starts from scratch. Provide the context explicitly, every time.

== Prompting Is a Skill

Prompting is not a parlour trick. It's not about discovering the one weird phrase that unlocks better output. It's a communication skill — and like all communication skills, it improves with practice, feedback, and deliberate attention.

The engineers who get the most out of agentic tools are the ones who treat prompting with the same rigour they apply to writing code. They think before they type. They specify before they implement. They verify before they move on.

That's not a new skill. That's just engineering.
