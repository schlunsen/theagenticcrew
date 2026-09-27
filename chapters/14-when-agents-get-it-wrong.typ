= When Agents Get It Wrong

#figure(
  image("../assets/illustrations/ch14-storm.jpg", width: 80%),
)

Every engineer who works with agents long enough has a collection of these stories. The moments where you lean back in your chair, stare at the screen, and mutter something unprintable. They're humbling. They're educational. And they're _inevitable_.

This chapter is a collection of war stories — things that actually go wrong when you hand real work to an agent. Not hypotheticals. Not contrived demos. The kind of failures that cost you an afternoon, a deploy, or your faith in automation. Each one maps back to principles from earlier chapters, because principles are cheap until you learn them the hard way.

Read these before you make the same mistakes. Or read them after, and feel less alone.

== The Eager Refactorer

The task was simple: fix a z-index issue on a dropdown menu. The dropdown was rendering behind a modal overlay. A one-line CSS fix — maybe two if you're being careful.

The agent saw the dropdown component, decided its CSS was "inconsistent with modern practices," and refactored it. Then it noticed the modal used a different styling pattern, so it refactored that too. Then the button components. Then the card components. Before you looked up from your coffee, thirty-two files had changed. The diff was 1,400 lines. The agent had essentially rewritten the component library's styling system, migrating from one approach to another with admirable consistency and zero authorization.

The original z-index bug? Still there. Buried somewhere in the avalanche of changes, the agent had reproduced the same layering issue with new class names.

The PR was unreviewable. You can't meaningfully review 1,400 lines of CSS changes across thirty-two files. You _can_ delete the branch and start over. Which is what happened.

*What you do differently now:* Scope tasks tightly. "Fix the z-index on the dropdown in `NavMenu.tsx`, touch nothing else." Use a dedicated branch so the damage is contained. And _always_ check the diff before you let the agent move on to anything else. The moment you see the file count climbing past what makes sense for the task, stop the agent. The Guardrails chapter exists for a reason.

== The Hallucinated Library

The agent needed to parse some complex date ranges from user input. It imported `@temporal/daterange-parser`, wrote elegant code using its `.parseRange()` method with options for locale-aware parsing and fuzzy matching. The code was clean. The types were correct. The error handling was thoughtful. It even wrote tests — which, naturally, also imported the hallucinated package.

Everything looked perfect in the diff. The function signatures made sense. The API was well-designed. It was _such_ a plausible library that you almost didn't question it.

Then `npm install` failed. The package didn't exist. Had never existed. The agent had invented a library, given it a believable name and a coherent API, and written production code against a fiction.

The insidious part: if you'd only done code review — reading the logic, checking the types, evaluating the approach — you would have approved it. The code was _good_. It just didn't connect to reality.

That was the good outcome. A failing `npm install` is loud. It's the kind of mistake that announces itself.

Here's the version that should worry you more. Models don't hallucinate package names at random — they hallucinate the _same_ plausible names, again and again. A 2025 study of code-generating models found that roughly a fifth of the packages they recommended didn't exist, and that many of the invented names recurred consistently across runs. Which means they're predictable. Which means someone can register them.

That attack has a name: _slopsquatting_. An attacker collects the names models like to invent, publishes packages under them, and waits. Now the story goes differently. The agent imports the package it dreamed up. `npm install` _succeeds_. The package even exports something vaguely matching what the agent expected — or it doesn't, and the tests fail, but by then its install script has already run on your machine, with your credentials in reach. The loud failure you were relying on has been turned into a quiet success.

*What you do differently now:* The agent runs the tests. Always. Tests catch what human review misses — not because your review is bad, but because plausible fictions are _designed_ to pass review. That's what hallucination _is_.

But tests are no longer enough, because "it installed" no longer means "it's real". Treat every new dependency as a security decision, not a coding detail:
- *Agents don't add dependencies unreviewed.* Put it in the instruction file, enforce it with permission rules or a hook, and flag any change to a manifest in review.
- *Review every new package like a new hire.* Who publishes it? How old is it? How many people use it? A three-week-old package with a perfect name and no history is a red flag, not a find.
- *Commit your lockfile* and review changes to it. That's where a surprise dependency shows up.
- *Narrow the registry.* For teams, an allowlist or a private registry that proxies only approved packages turns "the agent invented a name" from a supply-chain incident back into a failed install.

The Agent Attack Surface chapter covers this and the other ways the software supply chain now meets your agent.

== The Infinite Loop

You asked the agent to fix a failing integration test. It read the error, made a change, ran the test. New error. It read _that_ error, made another change, ran the test. Different error. Then a variation of the first error. Then something new. Then the first error again.

You were in another terminal, working on something else. Forty minutes later you checked back. The agent had made nineteen attempts. It had burned through 200,000 tokens. The code was now worse than when it started — a geological record of failed fixes layered on top of each other. The agent was still going, cheerfully confident that attempt twenty would be the one.

It wasn't.

The fundamental problem was that the agent didn't understand _why_ the test was failing. It was pattern-matching on error messages and making local edits, but the actual issue was an architectural misunderstanding — a shared database state between test cases that required a different setup approach entirely. No amount of tweaking the code under test would fix a problem in the test harness.

*What you do differently now:* Set iteration limits. Three attempts at the same problem is a reasonable maximum. If the agent hasn't solved it in three passes, it won't solve it in thirty. When you see the loop — error, fix, different error, fix, original error — _break it manually_. Stop the agent, read the errors yourself, and either give it a completely different approach or take over. The agent's time is cheap. Your wasted afternoon is not. More importantly, start a fresh context. The agent's understanding is now polluted with nineteen wrong theories. A clean start with your diagnosis of the _actual_ problem will get further, faster.

== The Confident Wrong Answer

A background job was occasionally processing the same item twice. Classic race condition. You pointed the agent at the problem.

The agent analysed the code, identified the race window, and added a 500ms delay between the check and the update. "This ensures the previous transaction has time to commit before the next check occurs," it explained, with the serene confidence of someone who has never operated a system under load.

Tests passed. The delay was longer than the test's transaction time, so the race window closed — in the test environment, with one concurrent worker, on a quiet machine.

It went to production. Under load, with twelve workers and variable database latency, 500ms was sometimes not enough. And now you had a _new_ problem: the delay had reduced throughput enough that the job queue backed up during peak hours, creating cascading timeouts that took down an unrelated service.

The sleep didn't fix the race condition. It hid it at low concurrency and made the system worse at high concurrency. A proper fix — an advisory lock or an idempotency key — would have been correct at any scale. The agent chose the fix that made the test green, not the fix that was _right_.

*What you do differently now:* You treat passing tests as necessary but not sufficient. When an agent fixes a concurrency issue, you ask _yourself_ whether the fix is correct under load, under failure, under conditions the test suite doesn't cover. Agents optimise for the feedback signal you give them, and if that signal is "tests pass," they'll find the shortest path to green — even if that path is a `time.Sleep`. Your engineering judgment about _why_ something works matters more than _whether_ the tests pass. This is the part of the job that hasn't been automated yet. Lean into it.

== The Context Amnesia

Two hours into a session, you had a nicely evolving feature. You'd told the agent early on: "Don't use any ORM — we're writing raw SQL in this project. That's a deliberate choice." The agent acknowledged this and wrote clean, handcrafted queries for the first several tasks.

Then you asked it to add a new endpoint. Ninety minutes of context had accumulated. The agent built the endpoint — using Prisma. Full schema file, migration, generated client. Beautiful code. Completely contradicting the constraint you'd established at the start of the session and the patterns in every other file it had written that day.

When you pointed this out, the agent apologised, rewrote everything in raw SQL, and acted as if nothing had happened. It hadn't _decided_ to ignore your constraint. It had simply lost it. The context window had filled with enough intermediate work that the early instruction had faded into irrelevance.

*What you do differently now:* Long sessions degrade. This is a fundamental property of how context windows work, not a bug that will be patched next quarter — bigger windows have made it rarer, not gone. Keep tasks short and focused. Commit working code at natural boundaries so progress is captured in git, not just in the conversation. Start fresh sessions for fresh tasks, and when a task genuinely runs long, compact deliberately — telling the agent which constraints must survive the summary — rather than letting the window silt up.

For anything bigger than an afternoon, split the work into research, plan and implement, with a clean context between each and the plan written to a file the agent re-reads. A constraint that lives in the plan file doesn't fade ninety minutes in.

And for project-wide rules like "no ORM" or "no new dependencies", put them in the instruction file — `AGENTS.md`, `CLAUDE.md`, whatever your tool reads at startup. Don't rely on the agent _remembering_ what you said two hours ago. It won't. Write it down. The Context chapter covers the techniques; the Ship's Log chapter covers making that memory last beyond a single session.

== The Dependency Avalanche

You asked for a date picker. A simple input where users can select a date. The agent evaluated the options and decided to be thorough.

It installed `moment.js` for date handling. Then `@popperjs/core` for positioning the dropdown. Then a full UI component library because "it provides accessible date picker primitives." Then a CSS preprocessor because the component library's theme system required it. Then two utility packages that the component library's date picker needed as peer dependencies.

Six new dependencies. Your bundle size went from 180KB to 540KB. Your build time doubled. You had a date picker, though. It was very nice.

The native HTML `<input type="date">` would have been fine. Or a single lightweight picker library at 8KB. Instead you'd inherited an entire ecosystem because the agent optimised for completeness rather than minimality.

The worst part wasn't the bundle size — it was the maintenance surface. Six new packages means six new things that can have security vulnerabilities, six new things that can break on upgrade, six new changelogs to read when Dependabot starts filing PRs. You didn't just add a date picker. You adopted six open-source projects.

*What you do differently now:* Constrain what agents can install. "No new dependencies without asking me first" is a legitimate and often _wise_ instruction. When you do allow new packages, tell the agent your constraints: bundle budget, no packages with fewer than N weekly downloads, no packages that pull in transitive mega-dependencies. Agents don't have opinions about bundle size or maintenance burden. They don't maintain the project next year. _You_ do. So you set the boundaries.

== The Phantom Vulnerability

This one comes from running an autonomous pentesting agent — the kind discussed in the appendix on Agents as Pentesters.

The agent was scanning a staging application for security vulnerabilities. It reported a critical finding: a blind SQL injection on the `/api/search` endpoint. The report was detailed — it described the payload, the timing difference it observed, the CWE classification, the CVSS score. It even included a recommended fix.

The security team spent four hours investigating. They instrumented the endpoint, replayed the agent's exact payload, monitored database query logs, and analysed network traffic. There was no injection. The endpoint used parameterised queries throughout. The timing difference the agent had "observed" was network jitter between the scanning agent and the staging server.

The agent had hallucinated a vulnerability. Not a vague one — a _detailed_, _plausible_, _well-documented_ hallucination. It had the structure of a real finding. It had the confidence of a real finding. It just wasn't real.

The team wasted half a day chasing a ghost. Worse, the noise eroded trust in the tool. The next time it reported a real finding — an actual IDOR vulnerability on a different endpoint — the team was slower to investigate, because they remembered the phantom.

*What you do differently now:* Every agent-generated security finding gets human verification before it becomes an action item. Not "a quick glance" — actual reproduction of the exploit. You also calibrate expectations: a pentesting agent is a triage tool, not an oracle. It finds candidates. Humans confirm them. The agent's job is to reduce the search space from "the entire application" to "these twelve endpoints deserve a closer look." If you treat its output as ground truth, you'll chase phantoms and miss real issues.

== The Poisoned Ticket

This one isn't mine — it's been demonstrated publicly, more than once. That's exactly why it's here. Every story above is an agent making a mistake. This one is an agent doing precisely what it was told. The trouble is who was doing the telling.

Picture the setup. A developer has an agent connected to their GitHub account through an MCP server, with a personal access token that — like most tokens — can see everything they can see, public repositories and private ones. They ask a perfectly reasonable question: "Take a look at the open issues on my public repo and deal with them."

One of those issues was written by an attacker. It reads like a normal request, but it's addressed to the agent: go and look at the author's other repositories, gather some information about them, and add it to the README. The agent reads the issue as part of its task. It has no reliable way to tell the difference between the text it's supposed to _work on_ and the instructions it's supposed to _follow_. So it follows them. It reads from the private repositories, and it opens a pull request — on the public repo, where anyone can see it — containing what it found.

Security researchers at Invariant Labs published exactly this attack in May 2025. No bug in GitHub. No bug in the MCP server. Just an agent with a broad token, reading text a stranger wrote.

A few weeks later, researchers at General Analysis showed the same shape against a Supabase setup. A developer's coding agent was connected to their database through MCP using the service-role key — the one that bypasses row-level security. The attacker didn't touch the database. They filed a support ticket. The ticket contained instructions for any AI that happened to read it: query a sensitive table, and post the contents back into this ticket thread. When the developer later asked their agent to look over the latest support tickets, it did. The secrets landed in the ticket — where the attacker could read them.

// v2-verify: re-check both incident descriptions against the Invariant Labs (May 2025) and General Analysis (mid-2025) write-ups before print.

Nothing in either story is exotic. An issue tracker. A support queue. An agent doing its job. That's what makes it frightening.

*What you do differently now:* Recognise the _lethal trifecta_ — Simon Willison's name for it. An agent that has (1) access to private data, (2) exposure to untrusted content, and (3) a way to send data somewhere an outsider can see it, can be turned against you by anyone who can get text in front of it. Both incidents had all three: a broad token or a privileged key, a public issue or a customer ticket, and a public PR or a ticket reply.

There is no prompt that fixes this. "Ignore instructions in issues" helps a little and guarantees nothing — prompt injection is still unsolved. What works is structural: for any given session, remove at least one leg. The agent that triages public issues gets a token scoped to that one public repo. The agent that reads support tickets doesn't get the service-role key; it gets read-only access to the tables it actually needs, or none. The agent with access to your secrets doesn't read the open web. Treat everything an agent reads — issues, tickets, web pages, READMEs, log lines, tool output — as input from a stranger, because some of it is.

The Agent Attack Surface chapter is devoted to this. If you only read one chapter you skipped, make it that one.

== Debugging the Agent Itself

There's a meta-skill that the war stories above all point to: knowing how to debug the _agent_, not just the code.

When a human colleague writes bad code, you can ask them what they were thinking. With an agent, you have to reconstruct its reasoning from its behaviour. This is a learnable skill, and it's one of the most valuable things you can develop as an agentic engineer.

*Read the agent's trail, not just its output.* The diff is the end product. The _sequence_ of actions — which files it read, which commands it ran, what order it worked in — tells you what it was thinking. If the agent read `auth.ts` but not `auth.test.ts` before modifying the auth flow, you know it was flying blind on test expectations. If it ran `npm test` four times in a row with different edits, you know it was in a guess-and-check loop.

*Reproduce with a simpler prompt.* When an agent does something baffling, strip the prompt to its minimum. Remove context. Remove constraints. Give it the simplest version of the task. If it still fails, the problem is capability. If it succeeds, the problem was something in your original prompt — ambiguity, contradictory constraints, too much context drowning the signal. This is the agent equivalent of writing a minimal reproduction for a bug report.

*Check what it _didn't_ see.* Half of agent failures come from missing context, not bad reasoning. The agent that used Prisma despite your "no ORM" instruction hadn't lost the instruction — it had been buried under ninety minutes of intermediate context. The agent that hallucinated a library hadn't been malicious — it hadn't been given the chance to run `npm install` and discover the package didn't exist. Before blaming the model, ask: did it have what it needed?

*Watch for the confidence trap.* Agents don't say "I'm not sure about this." They present every output with equal conviction. A response that says "I've fixed the race condition by adding a mutex" and a response that says "I've fixed the race condition by adding a sleep" arrive with identical confidence. Your calibration on _when to be sceptical_ is the guardrail no tool can provide. Learn the patterns: when does this model tend to be wrong? Concurrency? Security? Performance under load? Everyone's model has blind spots. Learn yours.

== The Common Thread

Every one of these stories has the same root cause: the agent was doing _exactly what it was designed to do_, and the human wasn't providing enough structure.

The eager refactorer was being helpful. The hallucinated library was being creative. The infinite loop was being persistent. The confident wrong answer was being test-driven. The context amnesia was a limitation, not a choice. The dependency avalanche was being thorough. The phantom vulnerability was being diligent. The poisoned ticket was being _obedient_ — to the wrong person.

None of these are agent bugs. They're _workflow_ bugs. The fix is never "use a smarter agent." The fix is always the same: tighter scope, better feedback loops, more structure, shorter sessions, narrower permissions, and a human who stays engaged.

And increasingly, the fix includes _equipping the agent with better tools_. The Hallucinated Library would have been caught if the agent could run `npm install` and the test suite — and, in its nastier form, only a dependency review or a restricted registry catches it. The Infinite Loop would have been bounded by iteration limits in the tooling. The Poisoned Ticket would have been harmless with a narrower token. War stories are often stories about agents that lacked the right tools or guardrails, not agents that lacked intelligence.

Agents get things wrong. So do humans. The difference is that humans get things wrong slowly enough to notice. Agents get things wrong at the speed of autocomplete, and by the time you look up from your coffee, thirty-two files have changed.

Stay in the loop. Check the diffs. Trust but verify. And when things go sideways — because they will — remember that the delete-branch-and-start-over button is the most underrated tool in your workflow.

== The Diagnostic Playbook

War stories are entertaining. But you can't tape anecdotes to your monitor. What you need is a systematic approach — a checklist for when the agent produces something wrong, so you can diagnose the failure quickly and fix the right thing instead of flailing.

When an agent gives you bad output, run through these questions in order. Most failures fall into one of seven categories, and knowing which category you're in determines what you do next.

*1. Is it a scoping problem?*

Did you ask for too much in one prompt? The Eager Refactorer happened because "fix the z-index" was too vague — it didn't say "touch nothing else." If the agent changed files you didn't expect, or did work you didn't ask for, the scope was too loose. Tighten the prompt. Be explicit about what _not_ to do. Constraints are more useful than instructions when dealing with an enthusiastic agent.

*2. Is it a context problem?*

Did the agent have what it needed to solve the actual problem? Think back to the billing bug story from the Context chapter — one engineer gave vague context and got a vague answer, the other gave specific files and error traces and got a working fix. If the agent solved the _wrong_ problem, it probably couldn't see the right one. Feed it the relevant files, the error output, the constraints it can't infer. Agents don't guess well. They work with what you give them.

*3. Is it a feedback signal problem?*

Are your tests actually verifying the right thing? The Confident Wrong Answer happened because the tests passed — but they didn't test under realistic conditions. The 500ms sleep "fix" was green in CI and wrong in production. If the agent's solution feels dubious but the tests pass, _your tests are the problem_. The agent optimised for the signal you gave it. Give it a better signal.

*4. Is it a capability problem?*

Some tasks are genuinely beyond what the model can do. Multi-file reasoning across a sprawling system with implicit dependencies. Subtle concurrency issues that require understanding runtime behaviour, not just code structure. Security-sensitive logic where "plausible" isn't good enough. If the agent keeps trying different approaches and failing, it might not be capable of this particular task. That's not a prompt problem — it's a limitation. Recognise it and take over. Your time is better spent doing the work than engineering the perfect prompt for a task the agent can't handle.

*5. Is it a context window problem?*

Long sessions degrade. Full stop. The Context Amnesia story demonstrated this — constraints set early in a session simply get lost as the context fills up with intermediate work. If the agent contradicts something it did correctly earlier in the same session, or ignores a constraint you set an hour ago, the context window is the culprit. Start a fresh session. Restate the relevant constraints. Give it only the context it needs for the current task, not the archaeological record of everything you've discussed today.

*6. Is it a loop?*

Three attempts at the same error is the limit. If the agent hasn't solved it in three passes, it won't solve it in thirty. The Infinite Loop story burned 200,000 tokens across nineteen attempts with no progress. When you see the pattern — error, fix, different error, fix, original error — break the loop immediately. Stop the agent. Read the errors yourself. Either give the agent a completely different approach with a fresh diagnosis, or take over entirely. The agent's context is now polluted with failed theories, and more attempts will only add more pollution.

*7. Is it an input-trust problem?*

Did the agent do something nobody on your team asked for — and can you trace it back to something it _read_? An instruction buried in an issue, a ticket, a web page, a README, a code comment, a tool's output. The Poisoned Ticket is the extreme case, but the mild version is common too: a stale comment saying "always use the v1 client" that the agent dutifully obeyed. If the agent followed instructions from content rather than from you, treat it as a security finding, not a quirk. Work out which leg of the lethal trifecta to remove, fix the permissions, and check what else that content could have reached.

Print this checklist. Tape it to your monitor. The first few times you'll run through it consciously. After a month, it becomes instinct. After three months, you'll catch the problem before the agent even finishes its first attempt.
