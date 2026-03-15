= Testing as the Feedback Loop

In traditional development, tests verify that your code works. In agentic engineering, tests do something more fundamental: they tell the agent whether it succeeded.

This changes everything about how you think about testing.

== The Agent's Eyes

An agent can't look at a UI and tell if it looks right. It can't feel whether an API response is "fast enough." It can't intuit whether a refactor preserved the subtle behaviour that users depend on. What it _can_ do is run your test suite and read the results.

Tests become the agent's primary feedback mechanism. Green means "keep going." Red means "try again." No tests means the agent is flying blind — guessing whether its changes work, with no way to verify.

This is why untested codebases are hard to work with agentically. It's not just a quality problem — it's an information problem. Without tests, the agent has no signal.

== TDD Takes on New Meaning

Test-Driven Development was always a good idea. With agents, it becomes a superpower.

Write the test first. Describe the expected behaviour. Then hand it to the agent and say: "make this pass." The agent now has a clear, unambiguous success criterion. It can iterate — write code, run the test, read the failure, adjust, repeat — in a tight loop that takes seconds per cycle.

This is fundamentally different from asking an agent to "build a login system." That's vague. But "make these fourteen tests pass" is precise. The agent knows exactly what success looks like, and it can measure its own progress.

The agentic engineer learns to express intent through tests. Every test is a contract. Every assertion is a requirement. The better your tests, the better your agents perform.

== Speed Matters

When an agent iterates in a test loop, the speed of your test suite directly affects productivity. A test suite that takes ten minutes to run means the agent waits ten minutes between attempts. A test suite that takes ten seconds means the agent can try dozens of approaches in the time it takes you to get coffee.

This creates a strong incentive to:
- Keep unit tests fast and isolated
- Separate fast tests from slow integration tests
- Use watch modes that re-run only affected tests
- Invest in test infrastructure the same way you invest in CI

Fast tests aren't just a developer experience improvement anymore. They're agent infrastructure.

== Testing Beyond Code

Agents don't just write application code. They write infrastructure configs, deployment scripts, documentation, and more. Each of these can — and should — have some form of automated verification.

Linting for config files. Link checkers for documentation. Schema validation for API contracts. Type checking as a fast feedback loop. Every automated check you add is another signal the agent can use to self-correct.

The agentic engineer thinks about testability broadly: not "does my function return the right value?" but "can I automatically verify that this change is correct?"

== The Virtuous Cycle

Here's what happens when you combine good tests with sandboxed agents: the agent makes a change, runs the tests, sees a failure, adjusts, runs again — all in its own isolated environment, all without your intervention. By the time it comes back to you, it's already verified its own work.

You review a diff that you know passes all tests. Your job shifts from "check if this works" to "check if this is the right approach." That's a much better use of your time.

This is the virtuous cycle of agentic engineering: better tests lead to more autonomous agents, which lead to faster iteration, which gives you more time to write better tests.
