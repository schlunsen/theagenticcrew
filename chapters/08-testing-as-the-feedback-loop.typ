= Testing as the Feedback Loop

Two codebases. Same agent. Same task: "Add a rate limiter to the API that returns 429 after 100 requests per minute per user."

In the first codebase, there are no tests. The agent reads the route handlers, picks a middleware insertion point, writes the rate-limiting logic, and... stops. It has no way to know if it worked. It can't start the server and send 101 requests to see what happens. It can't check whether existing endpoints still respond correctly. It produces a diff, says "I've added rate limiting," and hopes for the best. You review the code, squint at it, think it looks reasonable, merge it, and discover in production three days later that the middleware was mounted in the wrong order and never executed. Every request sailed through. The rate limiter was decoration.

In the second codebase, there's a test suite. The agent writes the rate-limiting middleware, then runs the tests. Two existing tests fail — a health check test that wasn't expecting middleware headers, and an auth test where the test setup was making 150 rapid requests and now gets throttled. The agent reads the failures, adjusts the middleware to skip the health endpoint, updates the test fixture to reset the rate counter between tests, and runs again. Green. Then it writes three new tests: one that verifies the 101st request returns 429, one that verifies the counter resets after a minute, and one that verifies different users have independent limits. All pass.

Same agent. Same task. Night and day outcomes. The difference was the test suite.

In traditional development, tests verify that your code works. In agentic engineering, tests do something more fundamental: they tell the agent whether it succeeded. This changes everything about how you think about testing.

== The Agent's Eyes

An agent can't look at a UI and tell if it looks right. It can't feel whether an API response is "fast enough." It can't intuit whether a refactor preserved the subtle behaviour that users depend on. What it _can_ do is run your test suite and read the results.

Tests become the agent's primary feedback mechanism. Green means "keep going." Red means "try again." No tests means the agent is flying blind — guessing whether its changes work, with no way to verify.

This is why untested codebases are hard to work with agentically. It's not just a quality problem — it's an information problem. Without tests, the agent has no signal. It's like asking someone to hang a picture frame while blindfolded. They might get it right, but you wouldn't bet on it.

And the quality of that signal matters enormously. A test that says `FAIL: expected 429, got 200` is actionable. The agent knows exactly what went wrong and can reason about why. A test that says `FAIL: assertion error` with no context is barely better than silence. The clarity of your test output is the clarity of the agent's vision.

== TDD Takes on New Meaning

Test-Driven Development was always a good idea. With agents, it becomes a superpower.

The workflow is simple: write the test first, then hand it to the agent and say "make this pass." The agent now has a clear, unambiguous success criterion. It can iterate — write code, run the test, read the failure, adjust, repeat — in a tight loop that takes seconds per cycle.

Here's what this looks like concretely. Say you need a function that parses a duration string like `"2h30m"` into total seconds. You write the test:

```python
def test_parse_duration():
    assert parse_duration("1h") == 3600
    assert parse_duration("30m") == 1800
    assert parse_duration("2h30m") == 9000
    assert parse_duration("45s") == 45
    assert parse_duration("1h15m30s") == 4530
    assert parse_duration("") == 0
    with pytest.raises(ValueError):
        parse_duration("abc")
```

Then you tell the agent: "Make `test_parse_duration` pass."

The agent's first attempt might handle hours and minutes but forget seconds. It runs the test: `FAIL: parse_duration("45s") returned 0, expected 45`. Clear signal. It adds seconds handling, runs again: `FAIL: parse_duration("abc") did not raise ValueError`. Another clear signal. It adds input validation. Green. Done.

Each cycle took seconds. The agent never needed to ask you what "correct" means — the tests defined it. And because the test covers edge cases you thought of up front, the implementation handles them from the start, not as bugs discovered later.

This is fundamentally different from asking an agent to "build a duration parser." That's vague. What format? What edge cases? What should happen with bad input? But "make these seven assertions pass" is precise. The agent knows exactly what success looks like, and it can measure its own progress toward it.

The agentic engineer learns to express intent through tests. Every test is a contract. Every assertion is a requirement. The better your tests, the better your agents perform. You stop thinking of test-writing as overhead and start thinking of it as _programming the agent_ — you're specifying behaviour in the most unambiguous language available: code that either passes or doesn't.

== What Makes a Good Agentic Test

Not all tests are equally useful for agents. The tests that serve humans well during development might actively mislead an agent. A good agentic test has specific properties, and they're worth being deliberate about.

*Fast.* An agent iterates in a loop. If each cycle takes ten minutes, the agent tries six approaches per hour. If each cycle takes ten seconds, it tries 360. Speed isn't just convenience — it's the difference between an agent that converges on a solution and one that times out. Run the full suite if it's fast; run just the relevant tests if it's not. Either way, the feedback loop needs to be tight.

*Deterministic.* A flaky test is worse than no test for an agent. When a test randomly fails, a human shrugs and reruns. An agent sees a failure and tries to fix it. It changes working code to chase a ghost. Then the flaky test passes — not because the agent's change was correct, but because the random stars aligned. Now you have a pointless code change that looks like a fix but isn't. The agent has been rewarded for doing nothing useful. If you have flaky tests, quarantine them before giving the agent access to the suite.

*Isolated.* Tests that depend on execution order, shared state, or external services create bewildering failures. The agent changes function A and test B fails — not because of a real dependency, but because test B relies on state that test A set up. The agent will spend cycles trying to understand a relationship between A and B that doesn't exist in the code, only in the test harness. Isolate your tests. Each one should set up its own world and tear it down.

*Clear error messages.* `AssertionError: False is not True` tells the agent nothing. `Expected user.status to be 'active' after calling activate(), but got 'pending'` tells it exactly what went wrong. Good assertion messages are free documentation. Use them. Custom error messages in your assertions are the cheapest investment you can make in agentic productivity.

*Focused on behaviour, not implementation.* A test that asserts the internal structure of a return value breaks when the agent refactors. A test that asserts the _behaviour_ — "given this input, I get this output" — survives refactors and gives the agent freedom to find better solutions. If your tests constrain the implementation too tightly, the agent can't improve it.

The litmus test: if you showed just the test file to a competent engineer with no other context, could they write a correct implementation? If yes, those tests will work well for an agent. If no — if the tests are too vague, too coupled, or too flaky to serve as a reliable specification — fix the tests before you hand them to the agent.

== The Coverage Question

"How much test coverage do I need for effective agentic work?"

The instinct is to say 100%. Full coverage. Every line, every branch, every path. But that's neither practical nor necessary. What you actually need is _targeted_ coverage: enough that the agent can verify the specific thing it's changing.

Think of it this way. If you ask an agent to modify the payment processing module, you need solid test coverage of payment processing. You don't necessarily need full coverage of the email templating system, the admin dashboard, or the CSV export feature. The agent needs tests around the code it's touching, plus enough integration tests to confirm it hasn't broken the interfaces between systems.

This leads to a practical strategy: _cover the hot paths first._ Look at where you'll actually point agents. Your core business logic. Your API contracts. Your data transformations. These are the areas that need rigorous tests — not because of abstract quality goals, but because these are the areas where agents will work.

Coverage metrics can even be misleading. A codebase with 90% line coverage but no tests on the payment flow is worse, for agentic purposes, than a codebase with 40% coverage that thoroughly tests payments, auth, and the API layer. The agent doesn't need a coverage badge. It needs tests where the work happens.

That said, integration tests have outsized value. A unit test tells the agent "this function works in isolation." An integration test tells the agent "these components work together." When an agent changes a function, the unit tests catch local regressions and the integration tests catch ripple effects. Both matter, but if you're starting from zero, integration tests give you more bang for the effort because they verify the _seams_ — the places where things tend to break.

One more thing: don't forget negative tests. Tests that verify your system _rejects_ bad input are critical for agents. Without them, an agent can "simplify" your validation logic, make all the positive tests pass, and leave you with a system that accepts garbage. If you have a validation rule, test both sides of it.

== Speed Matters

When an agent iterates in a test loop, the speed of your test suite directly affects productivity. A test suite that takes ten minutes to run means the agent waits ten minutes between attempts. A test suite that takes ten seconds means the agent can try dozens of approaches in the time it takes you to get coffee.

This creates a strong incentive to:
- Keep unit tests fast and isolated
- Separate fast tests from slow integration tests
- Use watch modes that re-run only affected tests
- Invest in test infrastructure the same way you invest in CI

Fast tests aren't just a developer experience improvement anymore. They're agent infrastructure.

Practically, this means you want a layered test strategy. A fast unit suite that runs in seconds — the agent's inner loop. A medium integration suite that runs in a minute — the agent runs this before calling the task done. And a slow end-to-end suite that runs in CI — the final verification before merge.

Tell your agents which suite to use. "Run `pytest tests/unit` after each change. Run `pytest tests/integration` when you think you're done." This keeps the inner loop fast while still catching integration issues before they reach you.

== Testing Beyond Code

Agents don't just write application code. They write infrastructure configs, deployment scripts, documentation, and more. Each of these can — and should — have some form of automated verification.

*Type checking* is the fastest feedback loop you can give an agent. A type error shows up in milliseconds, before a single test runs. In typed languages, or in Python with mypy, or in JavaScript with TypeScript, type checking catches a huge class of errors instantly. The agent renames a field, and the type checker immediately flags every place that references the old name. That's a tighter feedback loop than any test suite can provide.

*Linting and formatting* catch another class of issues. A misconfigured ESLint rule might seem like a minor annoyance, but to an agent, a lint failure is an unambiguous signal. "Your import is unused." "This variable is declared but never read." These are tiny corrections that add up to cleaner code with zero effort from you.

*Schema validation* for API contracts ensures the agent's changes don't break the interface between services. If you have OpenAPI specs, JSON Schema definitions, or GraphQL type definitions, validate against them. An agent that changes a response payload will immediately learn that it violated the contract, rather than discovering the break when a downstream service crashes in staging.

*Contract testing* between services takes this further. If service A depends on service B's API, a contract test verifies that B still satisfies what A expects — without needing to run both services simultaneously. When an agent modifies service B, the contract tests catch breaking changes that unit tests within B would miss entirely.

*Config file validation* is criminally underused. A YAML lint on your Kubernetes manifests. A terraform validate on your infrastructure code. A docker-compose config check. These take seconds to run and catch errors that would otherwise surface as mysterious failures during deployment. Every automated check you add is another signal the agent can use to self-correct.

The agentic engineer thinks about testability broadly: not "does my function return the right value?" but "can I automatically verify that this change is correct?"

== When Tests Mislead

Here's the uncomfortable truth: a bad test suite is worse than no test suite.

With no tests, the agent knows it's flying blind. It'll be conservative. It'll tell you it can't verify its changes. You'll review more carefully. The lack of signal is at least an honest lack of signal.

With bad tests, the agent flies with false confidence. It makes a change, the tests pass, and it reports success. You see green and relax your review. But the tests weren't actually verifying the right thing.

This happens in several predictable ways.

*Tests that test the mock, not the code.* When your test mocks out the database, the HTTP client, the filesystem, and the queue — and then asserts that the mocked function was called with the right arguments — you're testing your test setup, not your application logic. An agent can make the "real" code do absolutely anything and the test will still pass, as long as the mock expectations are met. These tests provide a green signal that means nothing.

*Tests that are too loose.* `assert response.status_code == 200` tells you the endpoint didn't crash. It doesn't tell you the response contains the right data. An agent could return an empty body, the wrong user's data, or a response missing half its fields, and that assertion would still pass. Specificity in assertions is specificity in the feedback signal.

*Tests that duplicate the implementation.* If your test essentially reimplements the function under test and checks that both return the same thing, it verifies nothing. The agent can change the implementation and the test together — and will, if it thinks they should match. You end up with code and tests that agree with each other but not with reality.

This connects directly to the "Confident Wrong Answer" pattern from the war stories chapter. The agent that added a `time.Sleep(500)` to fix a race condition? The tests passed. They passed because the test environment had low concurrency where 500ms was always enough. The tests were _technically correct_ but _practically misleading_. They gave a green signal for a fix that would fail under production load.

The defence is straightforward but requires discipline. Review your tests with the same rigour you review your code. Ask: "If the agent introduced a subtle bug, would this test catch it?" If the answer is no, the test is furniture — it makes the room look occupied but doesn't actually do anything.

== The Virtuous Cycle

Here's what happens when you put all of this together: good tests, fast feedback, sandboxed environments, and an agent in the loop.

The agent picks up a task. It reads the existing tests to understand expected behaviour. It makes a change. It runs the fast test suite — ten seconds. Two failures. It reads the error messages, understands the problem, adjusts. Runs again. Green. It writes new tests for the new behaviour. Runs the full integration suite — one minute. All green. It commits with a descriptive message, and hands you a diff that you know passes every automated check in your system.

You review a diff that you know passes all tests. Your job shifts from "check if this works" to "check if this is the right approach." That's a much better use of your time, and a much better use of your expertise. You're no longer a human test runner. You're an architect reviewing designs.

And here's the compounding effect. Every time an agent works on your codebase and the test suite helps it succeed, you've proven the value of those tests. Every time a missing test causes a bug, you feel the pain immediately — and you add the test. Your test suite grows in exactly the places that matter, guided by real feedback from real agentic work.

This is the virtuous cycle of agentic engineering: better tests lead to more autonomous agents, which lead to faster iteration, which gives you more time to write better tests. Each turn of the cycle makes the next one faster.

The engineers who will get the most out of agentic tools aren't the ones with the cleverest prompts or the most powerful models. They're the ones with the best test suites. A well-tested codebase is a force multiplier that compounds with every task you hand to an agent. An untested codebase is a tax that makes every task slower and riskier.

If you take one thing from this chapter, let it be this: before you optimise your prompts, before you experiment with new models, before you build elaborate orchestration — go write tests. Write them for the code your agents will touch. Make them fast, deterministic, isolated, and specific. That investment will pay off more than anything else in this book.

Your test suite is not overhead. It's the foundation everything else is built on.
