= When Agents Get It Wrong

Every engineer who works with agents long enough has a collection of these stories. The moments where you lean back in your chair, stare at the screen, and mutter something unprintable. They're humbling. They're educational. And they're _inevitable_.

This chapter is a collection of war stories — things that actually go wrong when you hand real work to an agent. Not hypotheticals. Not contrived demos. The kind of failures that cost you an afternoon, a deploy, or your faith in automation. Each one maps back to principles from earlier chapters, because principles are cheap until you learn them the hard way.

Read these before you make the same mistakes. Or read them after, and feel less alone.

== The Eager Refactorer

The task was simple: fix a z-index issue on a dropdown menu. The dropdown was rendering behind a modal overlay. A one-line CSS fix — maybe two if you're being careful.

The agent saw the dropdown component, decided its CSS was "inconsistent with modern practices," and refactored it. Then it noticed the modal used a different styling pattern, so it refactored that too. Then the button components. Then the card components. Before you looked up from your coffee, thirty-two files had changed. The diff was 1,400 lines. The agent had essentially rewritten the component library's styling system, migrating from one approach to another with admirable consistency and zero authorization.

The original z-index bug? Still there. Buried somewhere in the avalanche of changes, the agent had reproduced the same layering issue with new class names.

The PR was unreviewable. You can't meaningfully review 1,400 lines of CSS changes across thirty-two files. You _can_ delete the branch and start over. Which is what happened.

*What you do differently now:* Scope tasks tightly. "Fix the z-index on the dropdown in `NavMenu.tsx`, touch nothing else." Use a dedicated branch so the damage is contained. And _always_ check the diff before you let the agent move on to anything else. The moment you see the file count climbing past what makes sense for the task, stop the agent. The guardrails chapter exists for a reason.

== The Hallucinated Library

The agent needed to parse some complex date ranges from user input. It imported `@temporal/daterange-parser`, wrote elegant code using its `.parseRange()` method with options for locale-aware parsing and fuzzy matching. The code was clean. The types were correct. The error handling was thoughtful. It even wrote tests — which, naturally, also imported the hallucinated package.

Everything looked perfect in the diff. The function signatures made sense. The API was well-designed. It was _such_ a plausible library that you almost didn't question it.

Then `npm install` failed. The package didn't exist. Had never existed. The agent had invented a library, given it a believable name and a coherent API, and written production code against a fiction.

The insidious part: if you'd only done code review — reading the logic, checking the types, evaluating the approach — you would have approved it. The code was _good_. It just didn't connect to reality.

*What you do differently now:* The agent runs the tests. Always. If your setup doesn't allow that, you run them yourself before reviewing code. No exceptions. A failing `npm install` is a loud, obvious signal. A hallucinated API that was never executed is a silent bomb. Tests catch what human review misses — not because your review is bad, but because plausible fictions are _designed_ to pass review. That's what hallucination _is_.

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

*What you do differently now:* Long sessions degrade. This is a fundamental property of how context windows work, not a bug that will be patched next quarter. Keep tasks short and focused. Commit working code at natural boundaries so progress is captured in git, not just in the conversation. Start fresh sessions for fresh tasks. And for project-wide constraints like "no ORM" or "no new dependencies," put them in a `CLAUDE.md` file or equivalent that the agent reads at startup. Don't rely on the agent _remembering_ what you said two hours ago. It won't. Write it down.

== The Dependency Avalanche

You asked for a date picker. A simple input where users can select a date. The agent evaluated the options and decided to be thorough.

It installed `moment.js` for date handling. Then `@popperjs/core` for positioning the dropdown. Then a full UI component library because "it provides accessible date picker primitives." Then a CSS preprocessor because the component library's theme system required it. Then two utility packages that the component library's date picker needed as peer dependencies.

Six new dependencies. Your bundle size went from 180KB to 540KB. Your build time doubled. You had a date picker, though. It was very nice.

The native HTML `<input type="date">` would have been fine. Or a single lightweight picker library at 8KB. Instead you'd inherited an entire ecosystem because the agent optimised for completeness rather than minimality.

The worst part wasn't the bundle size — it was the maintenance surface. Six new packages means six new things that can have security vulnerabilities, six new things that can break on upgrade, six new changelogs to read when Dependabot starts filing PRs. You didn't just add a date picker. You adopted six open-source projects.

*What you do differently now:* Constrain what agents can install. "No new dependencies without asking me first" is a legitimate and often _wise_ instruction. When you do allow new packages, tell the agent your constraints: bundle budget, no packages with fewer than N weekly downloads, no packages that pull in transitive mega-dependencies. Agents don't have opinions about bundle size or maintenance burden. They don't maintain the project next year. _You_ do. So you set the boundaries.

== The Common Thread

Every one of these stories has the same root cause: the agent was doing _exactly what it was designed to do_, and the human wasn't providing enough structure.

The eager refactorer was being helpful. The hallucinated library was being creative. The infinite loop was being persistent. The confident wrong answer was being test-driven. The context amnesia was a limitation, not a choice. The dependency avalanche was being thorough.

None of these are agent bugs. They're _workflow_ bugs. The fix is never "use a smarter agent." The fix is always the same: tighter scope, better feedback loops, more structure, shorter sessions, and a human who stays engaged.

Agents get things wrong. So do humans. The difference is that humans get things wrong slowly enough to notice. Agents get things wrong at the speed of autocomplete, and by the time you look up from your coffee, thirty-two files have changed.

Stay in the loop. Check the diffs. Trust but verify. And when things go sideways — because they will — remember that the delete-branch-and-start-over button is the most underrated tool in your workflow.
